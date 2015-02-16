#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Gnarly')->no_columns->search(undef, {
   result_class => '::HRI',
});

cmp_deeply([$rs->all], [ { }, { }, { } ], 'no columns selected');

done_testing;
