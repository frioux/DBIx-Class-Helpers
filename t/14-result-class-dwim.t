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

my $expect = [ $rs->search(undef, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' })->all ];

ok scalar @{$expect}, 'make sure test environment is not ruined forever';

cmp_deeply [ $rs->search(undef, { result_class => '::HashRefInflator' })->all ], $expect, '::HashRefInflator works';

cmp_deeply [ $rs->search(undef, { result_class => '::HashRefInflator' })->all ], $expect, '::HRI works';

my $rs2 = $rs->search(undef);
$rs2->result_class('::HRI');
cmp_deeply [ $rs2->all ], $expect, '::HRI also works from result_class accessor';

done_testing;

