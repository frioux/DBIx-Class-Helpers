#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Search');

cmp_deeply
   [$rs->null('me.id')->all],
   [$rs->search({ 'me.id' => undef })->all],
   'null works the same';

cmp_deeply
   [$rs->null('.id', 'bar_id')->all],
   [$rs->search({ 'me.id' => undef, 'bar_id' => undef })->all],
   'null works the same for 2 params';

done_testing;
