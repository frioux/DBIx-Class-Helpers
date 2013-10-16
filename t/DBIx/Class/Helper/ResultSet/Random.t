#!perl

use lib 't/lib';
use Test::Roo;
with 'A::Does::TestSchema';

test basic => sub {
   my $schema = shift->schema;

   my $row = $schema->resultset('Foo')->rand->single;
   # testing actual randomness is hard, and it's not actually random anyway,
   # so suck it.
   ok $row->id >= 1 && $row->id <= 5, 'row is one of the rows from the database';

   my @rows = map $_->id, $schema->resultset('Foo')->rand(4)->all;
   ok @rows == 4, 'correct amount of rows selected';
   for (@rows) {
      ok $_ >= 1 && $_ <= 5, 'row is one of the rows from the database';
   }
};

run_me;
done_testing;
