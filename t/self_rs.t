#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

$schema->resultset('Foo_Bar')->populate([
   [qw(foo_id bar_id)],
   [1, 2],
   [2, 1],
   [4, 5],
]);

subtest 'single pk column' => sub {
   for ($schema->resultset('Bar')->all) {
      subtest 'Bar.id: ' . $_->id => sub {
         is ($_->self_rs->count, 1, 'single row in self_rs');
         is ($_->self_rs->single->id, $_->id, 'id matches');
      };
   }
};

subtest 'multi pk' => sub {
   for ($schema->resultset('Foo_Bar')->all) {
      subtest 'Foo_Bar: ' . $_->foo_id . ' ' . $_->bar_id => sub {
         is ($_->self_rs->count, 1, 'single row in self_rs');
         is ($_->self_rs->single->foo_id, $_->foo_id, 'foo_id matches');
         is ($_->self_rs->single->bar_id, $_->bar_id, 'bar_id matches');
      };
   }
};

done_testing;

