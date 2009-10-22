#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;

use TestSchema;

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

done_testing;
