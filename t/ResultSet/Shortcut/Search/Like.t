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
   [$rs->like('me.name', 'bar%')->all],
   [$rs->search({ 'me.name' => { '-like' => 'bar%' } })->all],
   'like works the same';

done_testing;
