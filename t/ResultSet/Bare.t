#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Foo');
my $rs2 = $schema->resultset('Foo')->search({ id => { '>=' => 3 } });

my $count = $rs->count;
ok($count != $rs2->count, 'Search actually finds a differing set of rows');
is($rs2->bare->count, $count, 'Bare clears search');

done_testing;
