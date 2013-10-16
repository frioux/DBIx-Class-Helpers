#!perl

use lib 't/lib';
use Test::Roo;
with 'A::Does::TestSchema';

test basic => sub {
   my $schema = shift->schema;

   my ($rs) = $schema->resultset('Foo')->search;
   my ($rs2) = $schema->resultset('Bar')->search;
   my ($rs3) = $schema->resultset('Foo')->first->bars;
   my ($rs4) = $schema->resultset('Bar')->first->foos;

   isa_ok $rs, 'DBIx::Class::ResultSet';
   isa_ok $rs2, 'DBIx::Class::ResultSet';
   isa_ok $rs3, 'DBIx::Class::ResultSet';
   isa_ok $rs4, 'DBIx::Class::ResultSet';
};

run_me;
done_testing;
