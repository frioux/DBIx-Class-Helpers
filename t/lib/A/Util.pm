package A::Util;

use strict;
use warnings;

use TestSchema;

sub connect {
   my ($engine, $storage_type, $on_connect_call) = @_;

   my $schema = 'TestSchema';
   $schema->storage_type('DBIx::Class::Storage::DBI'); # class methods: THE WORST
   $schema->storage_type('DBIx::Class::Storage::DBI::' . $storage_type)
      if $storage_type && !connected($engine, $on_connect_call);

   $schema = TestSchema->connect(@{connect_info($engine, $on_connect_call)});
   $schema->deploy if connected($engine, $on_connect_call);
   $schema->storage->dbh->{private_dbii_driver} = $engine;

   $schema
}

sub env {
   my $engine = shift;

   my $p = 'DBIITEST_' . uc($engine);
   $p . '_DSN', $p . '_USER', $p . '_PASSWORD';
}

sub connect_info {
   my ($engine, $on_connect_call) = @_;

   my @connect_info = grep $_, map $ENV{$_}, env($engine);
   push @connect_info, { on_connect_call => $on_connect_call }
      if @connect_info && $on_connect_call;

   return \@connect_info;
}

sub connected {
   return 1 if $_[0] eq 'SQLite';
   !!@{connect_info(@_)}
}

1;
