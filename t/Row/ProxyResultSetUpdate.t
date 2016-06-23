#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;
use Test::Fatal;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;
my $rs = $schema->resultset('Bloaty');

$rs->search({ id => 1000 })->delete;
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

$rs->search({ id => 1000 })->update({ id => 999 });
my $e = exception { $row->update({ literature => 'wonderful' }) };
like($e, qr/row not found/, 'dies when row gone missing');

#like($e, qr/updated more than one row/, 'dies when row ambiguous'); # not sure how to provoke this

done_testing;
