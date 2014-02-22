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

my $dupes_rs = $rs->search({}, { join => 'bars' });

ok($dupes_rs->has_rows, 'check rs has rows');

cmp_deeply
   [$dupes_rs->distinct->all],
   [$dupes_rs->search({},{distinct => 1})->all],
   'distinct works the same';

cmp_deeply
   [$dupes_rs->group_by(['me.id'])->all],
   [$dupes_rs->search({},{group_by => ['me.id']})->all],
   'group_by works the same';

cmp_deeply
   [$dupes_rs->order_by({ -desc => 'me.id' })->all],
   [$dupes_rs->search({},{order_by => { -desc => 'me.id' }})->all],
   'hashref order_by works the same';

cmp_deeply
   [$dupes_rs->order_by(['me.id'])->all],
   [$dupes_rs->search({},{order_by => { -asc => 'me.id' }})->all],
   'arrayref order_by works the same';

cmp_deeply
   [$dupes_rs->hri->all],
   [$dupes_rs->search({},{
       result_class => 'DBIx::Class::ResultClass::HashRefInflator'
   })->all],
   'hri works the same';

cmp_deeply
   [$dupes_rs->rows(2)->all],
   [$dupes_rs->search({},{rows => 2})->all],
   'rows works the same';

cmp_deeply
   [$dupes_rs->rows(2)->all],
   [$dupes_rs->limit(2)->all],
   'limit works the same';

cmp_deeply
   [$dupes_rs->page(1)->all],
   [$dupes_rs->search({},{page => 1})->all],
   'page works the same';

cmp_deeply
   [$dupes_rs->rows(2)->page(2)->all],
   [$dupes_rs->search({},{ rows => 2, page => 2 })->all],
   'page works the same';

cmp_deeply
   [$dupes_rs->get_page(2, 3)->all],
   [$dupes_rs->search({},{ page => 2, rows => 3 })->all],
   'get_page works the same';

cmp_deeply
   [$dupes_rs->get_page({ page => 2, rows => 3 })->all],
   [$dupes_rs->search({},{ page => 2, rows => 3 })->all],
   'get_page works the same';

cmp_deeply
   [$dupes_rs->get_page({ page => 2 })->all],
   [$dupes_rs->search({},{ page => 2 })->all],
   'get_page works the same';

cmp_deeply
   [$dupes_rs->get_page(2)->all],
   [$dupes_rs->get_page({ page => 2 })->all],
   'get_page works the same';

cmp_deeply
   [$dupes_rs->columns(['bar_id'])->all],
   [$dupes_rs->search({},{columns => ['bar_id']})->all],
   'columns works the same';

cmp_deeply
   [$dupes_rs->prefetch('bar')->all],
   [$dupes_rs->search({},{prefetch => 'bar' })->all],
   'prefetch works the same';

## Extended order_by syntax test
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
      [$dupes_rs->order_by($order)->all],
      [$dupes_rs->search({},{order_by => $expect})->all],
      "order_by works: $order";
}

done_testing;

