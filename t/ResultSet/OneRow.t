#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Gnarly');

isa_ok($rs->one_row, 'TestSchema::Result::Gnarly', '->one_row');

ok(!defined $rs->search({name => 'zzz'})->one_row, '->one_row for empty resultset');

is(my $row = $rs->one_row({name => 'frioux'})->name, 'frioux', '->one_row with condition');

ok(!$rs->one_row({name => 'zzz'}), '->one_row with condition that matches zero rows');

done_testing;

