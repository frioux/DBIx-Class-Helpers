#!perl

use lib 't/lib';
use Test::Deep 'cmp_deeply';
use Test::Roo;
with 'A::Does::TestSchema';

test 'simple json' => sub {
   my $schema = shift->schema;

   my $rs = $schema->resultset('Gnarly')->search(undef, {
      '+columns' => {
         old_gnarlies => $schema->resultset('Gnarly')
            ->correlate('gnarly_stations')
            ->search({ station_id => { '>' => 2 }})
            ->count_rs->as_query,
         new_gnarlies => $schema->resultset('Gnarly')
            ->correlate('gnarly_stations')
            ->search({ station_id => { '<=' => 2 }})
            ->count_rs->as_query,
      },
      result_class => '::HRI',
   });

   cmp_deeply([$rs->all], [
     {
       id => 1,
       literature => undef,
       name => "frew",
       new_gnarlies => 1,
       old_gnarlies => 1,
       your_mom => undef
     },
     {
       id => 2,
       literature => undef,
       name => "frioux",
       new_gnarlies => 1,
       old_gnarlies => 0,
       your_mom => undef
     },
     {
       id => 3,
       literature => undef,
       name => "frooh",
       new_gnarlies => 1,
       old_gnarlies => 0,
       your_mom => undef
     }

   ], 'relationship correlated correctly');
};

run_me;
done_testing;
