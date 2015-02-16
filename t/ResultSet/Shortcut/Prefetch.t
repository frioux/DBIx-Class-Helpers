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
   [$rs->prefetch('bar')->all],
   [$rs->search(undef,{prefetch => 'bar' })->all],
   'prefetch works the same';

done_testing;
