#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset( 'Foo' )->search({ id => { '>' => 0 } });
my $rs2 = $schema->resultset( 'Foo' )->search({ id => { '<' => 0 } });

ok( $rs->results_exist, 'check rs has some results' );
ok(!$rs2->results_exist, 'and check that rs has no results' );

done_testing;
