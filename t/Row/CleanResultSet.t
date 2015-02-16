#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

cmp_deeply
  $schema->resultset('Bar'),
  $schema->resultset('Bar')->first->clean_rs;

done_testing;

