package TestSchema;

use strict;
use warnings;

use File::Spec;

our $VERSION = 0.001;
use parent 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
   default_resultset_class => 'ResultSet',
);

__PACKAGE__->load_components(qw(
   Helper::Schema::LintContents
   Helper::Schema::QuoteNames
   Helper::Schema::DidYouMean
));

sub upgrade_directory { './t/lib' }

sub ddl_filename {
   my $self = shift;

   $_[2] = $self->upgrade_directory;

   $self->next::method(@_)
}

sub deploy_or_connect {
   my $self = shift;

   my $schema = $self->connect(@_);
   $schema->deploy();
   return $schema;
}

sub connection {
   my $self = shift;

   if (@_) {
      return $self->next::method(@_);
   } else {
      return $self->next::method('dbi:SQLite::memory:');
   }
}

sub generate_ddl {
   my $self = shift;
   my $schema = $self->connect;
   $schema->create_ddl_dir(
      $_,
      $schema->schema_version,
      undef,
      undef, {
          ($_ ne 'SQLite'
            ? (
                add_drop_table => 1,
                parser_args => { sources => ['HasDateOps', 'Gnarly'] })
            : ( add_drop_table => 0 )
         )
      },
   ) for qw(SQLite MySQL PostgreSQL SQLServer Oracle);
}

sub prepopulate {
   my $self = shift;
   $self->resultset($_)->delete for qw{Bar Foo Gnarly_Station Bloaty Gnarly Station HasAccessor};

   $self->populate( Gnarly => [
      [qw{id name}],
      [1,'frew'],
      [2,'frioux'],
      [3,'frooh'],
   ]);

   $self->populate( Station => [
      [qw{id name}],
      [1,'frew'],
      [2,'frioux'],
      [3,'frooh'],
   ]);

   $self->populate( Gnarly_Station => [
      [qw{gnarly_id station_id}],
      [1,1],
      [1,3],
      [2,1],
      [3,1],
   ]);

   $self->populate(Bloaty => [
      [qw{id name}],
      [1,1],
      [2,2],
      [3,3],
      [4,4],
      [5,5],
   ]);

   $self->populate(Foo => [
      [qw{id bar_id}],
      [1,1],
      [2,2],
      [3,3],
      [4,4],
      [5,5],
   ]);

   $self->populate(Bar => [
      [qw{id foo_id}],
      [1,1],
      [2,2],
      [3,3],
      [4,4],
      [5,5],
   ]);

   $self->populate( HasAccessor => [
      [qw{id usable_column unusable_column}],
      [1,'aa','bb'],
      [2,'cc','dd'],
      [3,'ee','ff'],
   ]);
}

'kitten eater';
