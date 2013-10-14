#!perl

use lib 't/lib';
use Test::Roo;
with 'A::Does::TestSchema';

test 'unloaded data' => sub {
   my $g = shift->schema->resultset('Gnarly')->search({
      id => 1
   })->single;

   is($g->id_plus_one, 2, 'basic test');
   is($g->id_plus_two, 3, 'slot and specified method');
   is($g->id_plus_two, 3, 'slot and specified method(2)');
};

test 'loaded data' => sub {
   my $g2 = shift->schema->resultset('Gnarly')->with_id_plus_one->search({
      id => 2
   })->single;

   is($g2->id_plus_one, 3, 'basic');
   is($g2->id_plus_two, 4, 'slot and specified method');
};

run_me;
done_testing;

