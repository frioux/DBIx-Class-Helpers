#!perl

use lib 't/lib';

use Test::Roo;
use TestSchema;
sub schema { 'TestSchema' }

test namespacing => sub {
   my $schema = shift->schema;

   my $foo_rs = $schema->resultset('Foo');
   my $bar_info = $foo_rs->result_source->relationship_info('bar');
   is $bar_info->{class}, 'TestSchema::Result::Bar', 'namespacing seems to work';

   my $bar_rs = $schema->resultset('Bar');
   my $foo_info = $bar_rs->result_source->relationship_info('foo');
   is $foo_info->{class}, 'TestSchema::Result::Foo', 'namespacing seems to work';
};

test table => sub {
   my $schema = shift->schema;

   my $foo_rs = $schema->resultset('Foo');
   is $foo_rs->result_source->from, 'Foo', 'set table works';

   my $bar_rs = $schema->resultset('Bar');
   is $bar_rs->result_source->from, 'Bar', 'set table works';
};

run_me;
done_testing;
