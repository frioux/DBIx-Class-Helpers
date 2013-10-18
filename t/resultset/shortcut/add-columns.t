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
   [$rs->search(undef, { columns => 'id' })->add_columns('bar_id')->all],
   [$rs->search(undef, { columns => ['id', 'bar_id'] })->all],
   'add_columns works the same';

done_testing;

