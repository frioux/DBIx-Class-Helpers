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
   [$rs->limited_page(2, 3)->all],
   [$rs->search({},{ page => 2, rows => 3 })->all],
   'limited_page works the same';

cmp_deeply
   [$rs->limited_page({ page => 2, rows => 3 })->all],
   [$rs->search({},{ page => 2, rows => 3 })->all],
   'limited_page works the same';

cmp_deeply
   [$rs->limited_page({ page => 2 })->all],
   [$rs->search({},{ page => 2 })->all],
   'limited_page works the same';

cmp_deeply
   [$rs->limited_page(2)->all],
   [$rs->limited_page({ page => 2 })->all],
   'limited_page works the same';

done_testing;

