#!perl

use lib 't/lib';
use Test::Deep 'cmp_deeply';
use Test::Roo;
with 'A::Does::TestSchema';

test 'remove columns' => sub {
   my $rs = shift->schema->resultset('Foo')->search({
      id => 1
   }, {
      result_class => 'DBIx::Class::ResultClass::HashRefInflator',
      'remove_columns' => ['bar_id'],
   });

   cmp_deeply [$rs->all], [{ id => 1 }], 'remove_columns works';

   cmp_deeply
      [$rs->search({ id => { '!=' => 4 } })->all],
      [{ id => 1 }],
      'chaining remove_columns works';;

   cmp_deeply
      [
         $rs->search({
            id => { '!=' => 4 }
         }, {
            '+columns' => 'bar_id'
         })->all
      ],
      [{ bar_id => 1, id => 1 }],
      'chaining and +columns works with remove_columns';
};

test 'autoremove columns' => sub {
   my $rs = shift->schema->resultset('Bloaty')->search({
      id => 1
   }, {
      result_class => 'DBIx::Class::ResultClass::HashRefInflator',
   });

   cmp_deeply [$rs->all], [{ id => 1 }], 'remove_columns works';

   cmp_deeply
      [$rs->search({ id => { '!=' => 4 } })->all],
      [{ id => 1 }],
      'chaining remove_columns works';;

   cmp_deeply
      [
         $rs->search({
            id => { '!=' => 4 }
         }, {
            '+columns' => 'name'
         })->all
      ],
      [{ name => 1, id => 1 }],
      'chaining and +columns works with remove_columns';
};

run_me;
done_testing;
