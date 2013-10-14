#!perl

use lib 't/lib';
use Test::Roo;
with 'A::Does::TestSchema';

test basic => sub {
   my $schema = shift->schema;

   my $r = $schema->resultset('Bar')->result_class;

   ok $r->has_relationship('foo'), 'has Foo';
   ok $r->has_relationship('foos'), 'has foos';
};

run_me;
done_testing;

