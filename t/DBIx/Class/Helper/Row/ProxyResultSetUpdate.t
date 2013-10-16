#!perl

use lib 't/lib';
use Test::Deep 'cmp_deeply';
use Test::Roo;
use TestSchema::ResultSet::Bloaty;
with 'A::Does::TestSchema';

test basic => sub {
   my $schema = shift->schema;

   $schema->resultset('Bloaty')->search({ id => 1000 })->delete;
   my $row = $schema->resultset('Bloaty')->create({
      id => 1000,
      name => 'woo',
      literature => 'bored',
      your_mom => 'hyuug',
   });

   $row->name('woot');

   $row->update({ literature => 'exciting' });

   cmp_deeply(
      [{
         name => 'woot',
         literature => 'exciting',
      }],
      \@TestSchema::ResultSet::Bloaty::stuff,
      'update correctly proxied',
   );
};

run_me;
done_testing;
