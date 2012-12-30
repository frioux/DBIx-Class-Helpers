package DBIx::Class::Helper::Schema::Serialize::Result;

use Moo;

has relationships => (
   is => 'ro',
   lazy => 1,
   builder => 'build_relationships',
);

sub build_relationships {
   [grep $_[0]->include_relationship($_), $_[0]->source->relationships];
}

sub include_relationship {
   my ($self, $relationship) = @_;

   $self->_included_sources->{$self->source->related_source($_)->source_name}
}

has columns => (
   is => 'ro',
   lazy => 1,
   builder => 'build_columns',
);

sub include_column {
   my ($self, $column) = @_;

   !$self->source->column_info($column)->{is_auto_increment} &&
      !$self->_autoinc_fk->{$column}
}

has _autoinc_fk => (
   is => 'ro',
   lazy => 1,
   builder => '_build_autoinc_fk',
);

sub _build_autoinc_fk {
   my $self = shift;

   my $source = $self->source;

   my %relationships = map {
      $_ => {
         info => $self->source->relationship_info($_),
         source => $self->source->related_source($_),
      },
   } $self->source->relationships;

   my %autoinc_fk;
   for my $r (keys %relationships) {
      my $easy_cond = $self->_fk_cond_unpack($relationships{$r}{info}{cond});

      my $other_src = $relationships{$r}{source};
      for my $other_col (keys %$easy_cond) {
         $autoinc_fk{$easy_cond->{$other_col}} = 1
            if $other_src->column_info($other_col)->{is_auto_increment}
      }
   }

   return \%autoinc_fk
}

sub build_columns {
   my $self = shift;

   my $source = $self->source;

   # TODO: column filter should be more generic
   [grep $self->include_column($_), $self->source->columns];
}

has serializer => (
   is => 'rw',
   handles => {
      _included_sources => 'included_sources',
   },
);

has source => (
   is => 'rw',
);

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

1;
