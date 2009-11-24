#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test::More;
use Test::Exception;

use TestSchema;
my $schema = TestSchema->connect('dbi:SQLite:dbname=dbfile');
$schema->deploy();
$schema->populate(Foo => [
   [qw{id bar_id}],
   [1,1],
   [2,2],
   [3,3],
   [4,4],
   [5,5],
]);

my $row = $schema->resultset('Foo')->rand->single;
# testing actual randomness is hard, and it's not actually random anyway,
# so suck it.
ok $row->id >= 1 && $row->id <= 5, 'row is one of the rows from the database';

done_testing;

END { unlink 'dbfile' unless $^O eq 'Win32' }
