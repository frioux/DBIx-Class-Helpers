#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;

use DBIx::Class::Helper::ResultClass::Tee;

my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Gnarly')->search(undef, {
   result_class => 'DBIx::Class::Helper::ResultClass::Tee',
});

ok $rs->count;
$rs->all;

ok 1;

done_testing;
