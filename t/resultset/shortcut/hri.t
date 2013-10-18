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
   [$rs->hri->all],
   [$rs->search(undef,{
       result_class => 'DBIx::Class::ResultClass::HashRefInflator'
   })->all],
   'hri works the same';

done_testing;
