#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test::More;

use TestSchema;

namespacing: {
   my $foo_rs = TestSchema->resultset('Foo');
   my $bar_info = $foo_rs->result_source->relationship_info('bar');
   is $bar_info->{class}, 'TestSchema::Result::Bar', 'namespacing seems to work';

   my $bar_rs = TestSchema->resultset('Bar');
   my $foo_info = $bar_rs->result_source->relationship_info('foo');
   is $foo_info->{class}, 'TestSchema::Result::Foo', 'namespacing seems to work';
}

table: {
   my $foo_rs = TestSchema->resultset('Foo');
   is $foo_rs->result_source->from, 'Foo', 'set table works';

   my $bar_rs = TestSchema->resultset('Bar');
   is $bar_rs->result_source->from, 'Bar', 'set table works';
}

done_testing;
