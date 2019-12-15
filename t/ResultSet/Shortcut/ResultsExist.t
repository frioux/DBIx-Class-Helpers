#!perl

use strict;
use warnings;

use Test::Roo;

use lib 't/lib';

with 'A::Role::TestConnect';

my $ran = 0;

top_test 'basic functionality' => sub {
  my $self = shift;
  my $schema = $self->schema;
  SKIP: {
    skip 'cannot test without a connection', 1 unless $self->connected;

    $ran++ if $self->engine eq 'SQLite';
    $schema->prepopulate;

    my $rs = $schema->resultset( 'Foo' )->search({ id => { '>' => 0 } });
    my $rs2 = $schema->resultset( 'Foo' )->search({ id => { '<' => 0 } });

    ok( $rs->results_exist, 'check rs has some results' );
    ok(!$rs2->results_exist, 'and check that rs has no results' );

    is_deeply(
       [
          $rs->search({}, { order_by => 'id', columns => {

             id => "id",

             has_lesser => $rs->search(
                { 'correlation.id' => { '<' => { -ident => "me.id" } } },
                { alias => 'correlation' }
             )->results_exist_as_query,

             has_greater => $rs->search(
                { 'correlation.id' => { '>' => { -ident => "me.id" } } },
                { alias => 'correlation' }
             )->results_exist_as_query,

          }})->hri->all
       ],
       [
          { id => 1, has_lesser => 0, has_greater => 1 },
          { id => 2, has_lesser => 1, has_greater => 1 },
          { id => 3, has_lesser => 1, has_greater => 1 },
          { id => 4, has_lesser => 1, has_greater => 1 },
          { id => 5, has_lesser => 1, has_greater => 0 },
       ],
       "Correlated-existence works",
    );
  }
};

run_me(SQLite => {
   engine => 'SQLite',
   connect_info => [ 'dbi:SQLite::memory:'],
});
run_me(Pg     => { engine => 'Pg'     });
run_me(mysql  => { engine => 'mysql'  });

ok $ran, 'tests were run against default SQLite';
done_testing;
