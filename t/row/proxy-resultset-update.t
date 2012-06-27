#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

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

done_testing;
