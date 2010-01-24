#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my ($rs) = $schema->resultset('Foo')->search;
my ($rs2) = $schema->resultset('Bar')->search;
my ($rs3) = $schema->resultset('Foo')->first->bars;
my ($rs4) = $schema->resultset('Bar')->first->foos;

isa_ok $rs, 'DBIx::Class::ResultSet';
isa_ok $rs2, 'DBIx::Class::ResultSet';
isa_ok $rs3, 'DBIx::Class::ResultSet';
isa_ok $rs4, 'DBIx::Class::ResultSet';

done_testing;
