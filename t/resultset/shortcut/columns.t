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
   [$rs->columns(['bar_id'])->all],
   [$rs->search(undef,{columns => ['bar_id']})->all],
   'columns works the same';

done_testing;
