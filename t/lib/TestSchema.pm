package TestSchema;

use strict;
use warnings;

use File::Spec;

our $VERSION = 0.001;
use parent 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
   default_resultset_class => 'ResultSet',
);

__PACKAGE__->load_components(qw/Schema::Versioned Helper::Schema::LintContents/);

sub dbfile { 'dbfile' }

sub upgrade_directory { './t/lib' }

sub ddl_filename {
   return File::Spec->catfile(shift->upgrade_directory, 'ddl.sql');
}

sub deploy_or_connect {
   my $self = shift;

   my $schema;
   unless ( -e $self->dbfile && [stat $self->dbfile]->[7] > 0 ) {
      $schema = $self->connect;
      $schema->deploy();
   } else {
      $schema = $self->connect
   }
   return $schema;
}

sub connect {
   my $self = shift;
   return $self->next::method('dbi:SQLite:dbname='.$self->dbfile);
}

sub generate_ddl {
   my $self = shift;
   my $schema = $self->connect;
   $schema->create_ddl_dir(
      'SQLite',
      $schema->schema_version,
      $self->upgrade_directory,
   );
}

sub prepopulate {
   my $self = shift;
   $self->resultset($_)->delete for qw{Bar Foo Gnarly_Station Bloaty Gnarly Station};

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
}

'kitten eater';
