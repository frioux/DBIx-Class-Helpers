#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;
use Test::Exception;

use TestSchema;
use TestSchema::Result::Bar;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

throws_ok(
   sub {
      TestSchema::Result::Bar->after_column_change(
         foo_id => {
            method => sub { 1; }
         },
         id => {
            method => sub { 1; }
         },
      );
   },
   qr/Invalid number of arguments\. One \$column => \$args pair at a time\./,
);

TestSchema::Result::Bar->after_column_change(
   foo_id => {
      method => sub { push @TestSchema::Result::Bar::events, [after_foo_id => $_[1], $_[2]] }
   },
);

TestSchema::Result::Bar->after_column_change(
   id => {
      method => sub {
         is($schema->storage->{transaction_depth}, 1, 'transactions turned on for id');
         push @TestSchema::Result::Bar::events, [after_id => $_[1], $_[2]]
      },
      txn_wrap => 1,
   },
);

my $another_txn_test = sub {
   is($schema->storage->{transaction_depth}, 0, 'transactions turned off for non-txn')
};

TestSchema::Result::Bar->around_column_change(
   foo_id => {
      method => sub {
         my ( $self, $fn, $old, $new ) = @_;
         push @TestSchema::Result::Bar::events, [pre_around_foo_id => $old, $new];
         $another_txn_test->();
         $fn->();
         push @TestSchema::Result::Bar::events, [post_around_foo_id => $old, $new];
      },
   },
);

my $first = $schema->resultset('Bar')->search(undef, { order_by => 'id' })->first;

is($first->foo_id, 1, 'foo_id starts as 1');
$first->foo_id(2);
$first->update;
is($first->foo_id, 2, 'foo_id is updated to 2');

$another_txn_test = sub {};

cmp_deeply([
  [ 'before_foo_id', 1, 2 ], # comes from TestSchema::Result::Bar
  [ 'pre_around_foo_id', 1, 2 ],
  [ 'post_around_foo_id', 1, 2 ],
  [ 'after_foo_id', 2, 2 ],
], \@TestSchema::Result::Bar::events, 'subs fire in correct order and with correct args');

@TestSchema::Result::Bar::events = ();

$first->update({ foo_id => 1, id => 99 });

is($first->foo_id, 1, 'foo_id is updated');
is($first->id, 99, 'id is updated');
cmp_deeply([
  [ 'before_foo_id', 2, 1 ],
  [ 'pre_around_foo_id', 2, 1 ],
  [ 'post_around_foo_id', 2, 1 ],
  [ 'after_id', undef, 99 ],
  [ 'after_foo_id', 1, 1 ]
], \@TestSchema::Result::Bar::events,
   '... even with args passed to update');

done_testing;
