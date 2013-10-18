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

cmp_deeply
   [$rs->order_by({ -desc => 'me.id' })->all],
   [$rs->search({},{order_by => { -desc => 'me.id' }})->all],
   'hashref order_by works the same';

cmp_deeply
   [$rs->order_by(['me.id'])->all],
   [$rs->search({},{order_by => { -asc => 'me.id' }})->all],
   'arrayref order_by works the same';

done_testing;
