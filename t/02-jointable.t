#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->connect('dbi:SQLite:dbname=dbfile');
$schema->deploy();
$schema->populate( Gnarly => [
   [qw{id name}],
   [1,'frew'],
   [2,'frioux'],
   [3,'frooh'],
]);

$schema->populate( Station => [
   [qw{id name}],
   [1,'frew'],
   [2,'frioux'],
   [3,'frooh'],
]);

$schema->populate( Gnarly_Station => [
   [qw{gnarly_id station_id}],
   [1,1],
   [1,3],
   [2,1],
   [3,1],
]);

{
   my $bar_rs = TestSchema->resultset('Foo_Bar');

   is $bar_rs->result_source->from, 'Foo_Bar', 'set table works';

   relationships: {
      my $bar_info = $bar_rs->result_source->relationship_info('bar');
      is $bar_info->{class}, 'TestSchema::Result::Bar',
         'namespace correctly defaulted';

      my $foo_info = $bar_rs->result_source->relationship_info('foo');
      is $foo_info->{class}, 'TestSchema::Result::Foo',
         'namespace correctly defaulted';
   }

   cmp_deeply [ $bar_rs->result_source->primary_columns ], [qw{foo_id bar_id}],
      'set primary keys works';
}

{
   relationships: {
      my $g_rs = $schema->resultset('Gnarly');
      my $s_rs = $schema->resultset('Station');
      my $g_s_rs = $schema->resultset('Gnarly_Station');

      is $s_rs->result_source->relationship_info('gnarly_stations')->{class},
         'TestSchema::Result::Gnarly_Station',
         'Left has_many defaulted correctly';

      is $g_rs->result_source->relationship_info('gnarly_stations')->{class},
         'TestSchema::Result::Gnarly_Station',
         'Right has_many defaulted correctly';

      cmp_deeply [ map $_->id, $s_rs->find(1)->gnarlies ],
         [ 1, 2, 3 ],
         'Left many_to_many defaulted correctly';

      cmp_deeply [ map $_->id, $g_rs->find(1)->stations ],
         [ 1, 3 ],
         'Right many_to_many defaulted correctly';

   }
}

done_testing;
END { unlink 'dbfile' }
