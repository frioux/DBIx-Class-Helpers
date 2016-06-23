#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $r = $schema->resultset('Bar')->result_class;

ok $r->has_relationship('foo'), 'has Foo';
ok $r->has_relationship('foos'), 'has foos';
ok $r->has_relationship('might_have_foo'), 'might have Foo';
ok $r->has_relationship('has_one_foo'), 'has one Foo';

done_testing;

