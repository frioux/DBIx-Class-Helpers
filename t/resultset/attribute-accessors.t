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
   'order_by works the same';

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
   [$dupes_rs->columns(['bar_id'])->all], 
   [$dupes_rs->search({},{columns => ['bar_id']})->all],
   'columns works the same';

cmp_deeply
   [$dupes_rs->prefetch('bar')->all],
   [$dupes_rs->search({},{prefetch => 'bar' })->all],
   'prefetch works the same';

done_testing;

