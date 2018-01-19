#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();

$schema->prepopulate;

my $rs = $schema->resultset( 'Foo' )->search({ id => { '>' => 0 } });
my $rs2 = $schema->resultset( 'Foo' )->search({ id => { '<' => 0 } });

ok( $rs->results_exist, 'check rs has some results' );
ok(!$rs2->results_exist, 'and check that rs has no results' );

is_deeply(
   [
      $rs->search({}, { order_by => 'id', columns => {

         id => "id",

         has_lesser => $rs->search(
            { 'correlation.id' => { '<' => { -ident => "me.id" } } },
            { alias => 'correlation' }
         )->results_exist_as_query,

         has_greater => $rs->search(
            { 'correlation.id' => { '>' => { -ident => "me.id" } } },
            { alias => 'correlation' }
         )->results_exist_as_query,

      }})->hri->all
   ],
   [
      { id => 1, has_lesser => 0, has_greater => 1 },
      { id => 2, has_lesser => 1, has_greater => 1 },
      { id => 3, has_lesser => 1, has_greater => 1 },
      { id => 4, has_lesser => 1, has_greater => 1 },
      { id => 5, has_lesser => 1, has_greater => 0 },
   ],
   "Correlated-existence works",
);


use A::Util;

for my $engine (qw(Pg mysql)) {
   my $s = A::Util::connect($engine);

   subtest $engine => sub {
      plan skip_all => 'no availabe engine: ' . $engine
         unless A::Util::connected($engine);
      ok( !$s->resultset('Gnarly')->results_exist, 'no results yet');

      $s->resultset('Gnarly')->create({ id => 1, name => "frew" });
      ok( $s->resultset('Gnarly')->results_exist, 'results');
   };
}

done_testing;
