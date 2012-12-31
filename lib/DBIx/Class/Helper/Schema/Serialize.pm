package DBIx::Class::Helper::Schema::Serialize;

# it might be stupid to make this methods; maybe just subs?

use Moo;
use DBIx::Class::Helper::Schema::Serialize::Result;

use Scalar::Util qw(blessed weaken);

sub _transform_source_arg { [map blessed $_ ? $_->source_name : $_, @{$_[1]}] }

has starting_points => (
   is => 'ro',
   required => 1,
);

has schema => (
   is => 'ro',
   required => 1,
   handles => [qw(sources source)],
);

has included_sources => (
   is => 'ro',
   lazy => 1,
   builder => 'build_included_sources',
   init_arg => 'resolved_included_sources',
);

has _source_serializers => (
   is => 'ro',
   init_arg => 'source_serializers',
   default => sub { {} },
);

has source_serializers => (
   is => 'ro',
   lazy => 1,
   init_arg => undef,
   builder => 'build_source_serializers',
);

sub build_source_serializers {
   my $self = shift;

   my $ret = $self->_source_serializers;

   for my $source (keys %{$self->included_sources}) {
      my $r = $ret->{$source} ||=
         DBIx::Class::Helper::Schema::Serialize::Result->new(
            serializer => $self,
         );
      $r->source($self->source($source));
      $r->serializer($self);
   }

   $ret
}

sub build_included_sources {
   my $self = shift;

   my %included_sources;
   if (my $w = $self->_included_sources) {
      %included_sources = map { $_ => 1 } @{$self->_transform_source_arg($w)}
   } elsif (my $b = $self->_excluded_sources) {
      my %excluded = map { $_ => 1 } @{$self->_transform_source_arg($b)};

      %included_sources = map { $_ => 1 }
         grep !$excluded{$_}, map $self->source($_), $self->sources
   } else {
      %included_sources = map { $_ => 1 } $self->sources
   }

   \%included_sources
}

has _included_sources => (
   is => 'ro',
   init_arg => 'included_sources',
);

has _excluded_sources => (
   is => 'ro',
   init_arg => 'excluded_sources',
);

sub serialize {
   my ($self, $args) = @_;

   my %included_sources =  %{$self->included_sources};
   my $ret = {
      all_data => {
         map { $_ => {} } keys %included_sources
      },
      init_data => {
         map { $_->result_source->source_name => [] } @{$self->starting_points}
      },
   };

   for my $rs (@{$self->starting_points}) {
      my $source_name = $rs->result_source->source_name;
      die 'you dummy!' unless $included_sources{$source_name};

      $self->serialize_resultset(
         $rs, $ret, $ret->{init_data}{$source_name}
      );
   }

   for (keys %{$ret->{all_data}}) {
      $ret->{all_data}{$_} = [values %{$ret->{all_data}{$_}}]
   }

   return $ret->{init_data};
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

   my $source_serializer = $self->source_serializers->{$source->source_name};

   my $source_store = $conf->{all_data}{$source->source_name};

   my @pk = $source->primary_columns;

   ROW:
   while (my $row = $rs->next) {
      my $pk = join "\0", map $row->get_column($_), @pk;
      next ROW if $source_store->{$pk};

      my $obj = {
         columns => {
            map { $_ => $row->get_column($_) } @{$source_serializer->columns},
         }
      };
      $source_store->{$pk} = $obj;
      if ($stuff) {
         my $ref = $obj;
         weaken($ref);
         push @$stuff, $ref
      }

      for (@{$source_serializer->relationships}) {
         my $r;

         if ($source_serializer->include_relationships) {
            $conf->{all_data}{$source->source_name}->{$pk}{rels} ||= {};
            $r = [];
            $conf->{all_data}{$source->source_name}->{$pk}{rels}{$_} = $r;
         }

         $self->serialize_resultset(
            scalar $row->related_resultset($_),
            $conf,
            $r,
         );
      }
   }
}

1;
