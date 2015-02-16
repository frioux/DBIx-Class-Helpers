#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Foo');

my %tests = (
    'id'         => [{ -asc => 'me.id' }],
    '!id'        => [{ -desc => 'me.id' }],
    'id,!bar_id'   => [{ -asc => 'me.id' }, { -desc => 'bar_id' }],
    'id, !bar_id'  => [{ -asc => 'me.id' }, { -desc => 'bar_id' }],
    'id ,!bar_id'  => [{ -asc => 'me.id' }, { -desc => 'bar_id' }],
    'id , !bar_id' => [{ -asc => 'me.id' }, { -desc => 'bar_id' }],
);

while (my ($order, $expect) = each(%tests)) {
   cmp_deeply
      [$rs->order_by($order)->all],
      [$rs->search({},{order_by => $expect})->all],
      "order_by works: $order";
}

done_testing;
