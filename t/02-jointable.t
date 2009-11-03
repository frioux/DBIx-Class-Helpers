#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;

use TestSchema;

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
      my $g_rs = TestSchema->resultset('Gnarly');
      my $s_rs = TestSchema->resultset('Station');
      my $g_s_rs = TestSchema->resultset('Gnarly_Station');

      is $s_rs->result_source->relationship_info('gnarly_stations')->{class},
         'TestSchema::Result::Gnarly_Station',
         'Left has_many defaulted correctly';

      is $g_rs->result_source->relationship_info('gnarly_stations')->{class},
         'TestSchema::Result::Gnarly_Station',
         'Right has_many defaulted correctly';

      is $s_rs->result_source->relationship_info('gnarlies')->{class},
         'TestSchema::Result::Gnarly',
         'Left many_to_many defaulted correctly';

      is $g_rs->result_source->relationship_info('stations')->{class},
         'TestSchema::Result::Station',
         'Right many_to_many defaulted correctly';

   }
}

done_testing;
