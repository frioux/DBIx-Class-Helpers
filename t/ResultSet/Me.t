#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();

my $rs = $schema->resultset('Gnarly');
my $alias = $rs->current_source_alias;

is $rs->me, "$alias.", 'me without args';
is $rs->me('col'), "$alias.col", 'me with args';

done_testing;
