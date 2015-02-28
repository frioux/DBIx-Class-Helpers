#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal 'dies_ok';

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

$schema->resultset('Gnarly')->update({ literature => 'boo.' });
$schema->resultset('Gnarly')->create({ id => 4, name => 'fismboc' });
my $rs = $schema->resultset('Gnarly')->search({ literature => 'boo.' });

is($rs->count, 3, 'base rs has three results');

my $rs2 = $schema->resultset('Gnarly')->search({ name => 'frew' });

is($rs2->count, 1, 'rs2 has 1 result');
my $rs3 = $schema->resultset('Gnarly')->search({ name => 'frioux' });
is($rs3->count, 1, 'rs3 has 1 result');
my $rs4 = $schema->resultset('Gnarly')->search({ name => 'fismboc' });
is($rs4->count, 1, 'rs4 has 1 result');

is($rs->search_or([$rs2, $rs3, $rs4])->count, 2, 'only two things are in all of rs and in any of rs2, rs3, or rs4');

dies_ok { $rs->search_or([$schema->resultset('Bloaty')]) } 'or-ing differing ResultSets dies';

done_testing;
