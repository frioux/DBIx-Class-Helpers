package A::Role::TestConnect;

use Moo::Role;
use TestSchema;

has [qw(on_connect_call engine)] => ( is => 'ro' );

has storage_type => (
   is => 'ro',
   lazy => 1,
   default => sub { shift->engine }
);

sub connected { !!@{shift->connect_info} }

has connect_info => (
   is => 'ro',
   lazy => 1,
   default => sub {
      my $self = shift;
      my @connect_info = grep $_, map $ENV{$_}, $self->env_vars;
      push @connect_info, { on_connect_call => $self->on_connect_call }
         if @connect_info && $self->on_connect_call;

      return \@connect_info;
   },
);

sub env_vars {
   my $self = shift;

   my $p = 'DBIITEST_' . uc($self->engine);
   $p . '_DSN', $p . '_USER', $p . '_PASSWORD';
}

has schema => (
   is => 'ro',
   lazy => 1,
   builder => sub {
      my $self = shift;

      my $schema = 'TestSchema';
      $schema->storage_type('DBIx::Class::Storage::DBI'); # class methods: THE WORST
      $schema->storage_type('DBIx::Class::Storage::DBI::' . $self->storage_type)
         if $self->storage_type && !$self->connected;

      $schema = TestSchema->connect(@{$self->connect_info});
      $schema->deploy if $self->connected;
      $schema->storage->dbh->{private_dbii_driver} = $self->engine;

      $schema
   },
);

1;
