#!perl

use lib 't/lib';
use Test::Roo;
with 'A::Does::TestSchema';

around build_schema => sub {
   my ($orig, $self) = @_;

   my $schema = $self->$orig;

   $schema->resultset('Foo_Bar')->delete;
   $schema->resultset('Foo_Bar')->populate([
      [qw(foo_id bar_id)],
      [1, 2],
      [2, 1],
      [4, 5],
   ]);

   $schema;
};

test 'single pk column' => sub {
   my $schema = shift->schema;

   for ($schema->resultset('Bar')->all) {
      subtest 'Bar.id: ' . $_->id => sub {
         is ($_->self_rs->count, 1, 'single row in self_rs');
         is ($_->self_rs->single->id, $_->id, 'id matches');
      };
   }
};

test 'multi pk' => sub {
   my $schema = shift->schema;

   for ($schema->resultset('Foo_Bar')->all) {
      subtest 'Foo_Bar: ' . $_->foo_id . ' ' . $_->bar_id => sub {
         is ($_->self_rs->count, 1, 'single row in self_rs');
         is ($_->self_rs->single->foo_id, $_->foo_id, 'foo_id matches');
         is ($_->self_rs->single->bar_id, $_->bar_id, 'bar_id matches');
      };
   }
};

run_me;
done_testing;

