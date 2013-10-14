#!perl

use lib 't/lib';
use Test::Exception;
use Test::Roo;
with 'A::Does::TestSchema';

test basic => sub {
   my $schema = shift->schema;

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
};

run_me;
done_testing;
