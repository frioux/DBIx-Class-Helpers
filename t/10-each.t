#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

ok $schema
  ->resultset('Foo')
  ->each(sub {
    my ($each, $row) = @_;
    warn $each->count;
    warn $row->id;
  });


done_testing;


