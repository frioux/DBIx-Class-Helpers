#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test::More;

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

my $rs = $schema->resultset('Foo')->search({ id => 1 });
my $rs2 = $schema->resultset('Foo')->search({ id => { '>=' => 3 } });

use Devel::Dwarn;

Dwarn [ map $_->id, $rs2->union($rs)->all ];

done_testing;

END { unlink 'dbfile' unless $^O eq 'Win32' }
