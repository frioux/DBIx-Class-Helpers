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

done_testing;

