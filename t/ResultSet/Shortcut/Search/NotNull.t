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
   [$rs->not_null(['me.id'])->all],
   [$rs->search({ 'me.id' => { '!=' => undef } })->all],
   'not_null works the same';

done_testing;
