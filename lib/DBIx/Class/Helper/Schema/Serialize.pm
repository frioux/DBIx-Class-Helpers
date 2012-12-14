package DBIx::Class::Helper::Schema::Serialize;

# it might be stupid to make this methods; maybe just subs?

use strict;
use warnings;

use Scalar::Util qw(blessed weaken);

sub _transform_source_arg { [map blessed $_ ? $_->source_name : $_, @{$_[1]}] }

sub serialize {
   my ($self, $args) = @_;

   my @starting_points = @{$args->{starting_points}||[]};

   die 'dummy!' unless @starting_points;

   my %included_sources;
   if (my $w = $args->{included_sources}) {
      %included_sources = map { $_ => 1 } @{$self->_transform_source_arg($w)}
   } elsif (my $b = $args->{excluded_sources}) {
      my %excluded = map { $_ => 1 } @{$self->_transform_source_arg($b)};

      %included_sources = map { $_ => 1 }
         grep !$excluded{$_}, map $self->source($_), $self->sources
   } else {
      %included_sources = map { $_ => 1 } $self->sources
   }

   my $ret = {
      data => {
         map { $_ => {} } keys %included_sources
      },
      included_sources => \%included_sources,
   };

   for my $rs (@starting_points) {
      die 'you dummy!' unless $included_sources{$rs->result_source->source_name};

      $self->serialize_resultset($rs, $ret);
   }

   return $ret->{data};
}

# taken from linter
sub _fk_cond_unpack {
   my ($self, $cond) = @_;

   return {
      map {
         my $k = $_;
         my $v = $cond->{$_};
         $_ =~ s/^(self|foreign)\.// for $k, $v;

         ($k => $v)
      } keys %$cond
   }
}

sub serialize_resultset {
   my ($self, $rs, $conf, $stuff) = @_;

   my $source = $rs->result_source;

   my @pk = $source->primary_columns;

   my %relationships = map {
      $_ => {
         info => $source->relationship_info($_),
         source => $source->related_source($_),
      },
   } $source->relationships;

   my %autoinc_fk;
   for my $r (keys %relationships) {
      my $easy_cond = $self->_fk_cond_unpack($relationships{$r}{info}{cond});

      my $other_src = $relationships{$r}{source};
      for my $other_col (keys %$easy_cond) {
         $autoinc_fk{$easy_cond->{$other_col}} = 1
            if $other_src->column_info($other_col)->{is_auto_increment}
      }
   }

   # TODO: column filter should be more generic
   my @columns = grep
      !$source->column_info($_)->{is_auto_increment} &&
      !$autoinc_fk{$_},
   $source->columns;

   my @rels = grep
      $conf->{included_sources}{$source->related_source($_)->source_name},
      $source->relationships;

   my $source_store = $conf->{data}{$source->source_name};

   ROW:
   while (my $row = $rs->next) {
      my $pk = join "\0", map $row->get_column($_), @pk;
      next ROW if $conf->{data}{$source->source_name}->{$pk};

      my $obj = {
         columns => {
            map { $_ => $row->get_column($_) } @columns,
         }
      };
      $conf->{data}{$source->source_name}->{$pk} = $obj;
      if ($stuff) {
         my $ref = $obj;
         weaken($ref);
         push @$stuff, $ref
      }

      for (@rels) {
         $conf->{data}{$source->source_name}->{$pk}{rels} ||= {};
         my $r = [];
         $conf->{data}{$source->source_name}->{$pk}{rels}{$_} = $r;
         $self->serialize_resultset(
            scalar $row->related_resultset($_),
            $conf,
            $r,
         );
      }
   }
}

1;
