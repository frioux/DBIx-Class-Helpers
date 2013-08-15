#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $g = $schema->resultset('Gnarly')->search({
   id => 1
})->single;

subtest 'unloaded data' => sub {
   is($g->id_plus_one, 2, 'basic test');
   is($g->id_plus_two, 3, 'slot and specified method');
   is($g->id_plus_two, 3, 'slot and specified method(2)');
};

my $g2 = $schema->resultset('Gnarly')->with_id_plus_one->search({
   id => 2
})->single;

subtest 'loaded data' => sub {
   is($g2->id_plus_one, 3, 'basic');
   is($g2->id_plus_two, 4, 'slot and specified method');
};

subtest 'copy result' => sub {
    ok !$schema->resultset('Gnarly')->search({ id => 100 })->count,
       'will not accidentally collide';
    ok my $g3 = $g->copy({ id => 100 }), 'Copied result';
    isa_ok $g3, 'DBIx::Class::Row';
    is $g3->id, 100, 'id is correctly overridden';
};

done_testing;

