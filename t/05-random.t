#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Exception;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $row = $schema->resultset('Foo')->rand->single;
# testing actual randomness is hard, and it's not actually random anyway,
# so suck it.
ok $row->id >= 1 && $row->id <= 5, 'row is one of the rows from the database';

my @rows = map $_->id, $schema->resultset('Foo')->rand(4)->all;
ok @rows == 4, 'correct amount of rows selected';
for (@rows) {
   ok $_ >= 1 && $_ <= 5, 'row is one of the rows from the database';
}


done_testing;
