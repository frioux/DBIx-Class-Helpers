#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use TestSchema;

ok my $schema = TestSchema->deploy_or_connect();
ok $schema->prepopulate;

{
    my @expected = (
      { id=>1, count=>1, index=>0, first=>1, even=>0, odd=>1 },
      { id=>2, count=>2, index=>1, first=>0, even=>1, odd=>0 },
      { id=>3, count=>3, index=>2, first=>0, even=>0, odd=>1 },
      { id=>4, count=>4, index=>3, first=>0, even=>1, odd=>0 },
      { id=>5, count=>5, index=>4, first=>0, even=>0, odd=>1 },
    );

    ok $schema
      ->resultset('Foo')
      ->each(sub {
        my ($each, $row) = @_;
        my $expected = shift @expected;

        is $row->id, $expected->{id},
          'Got $row->id of ('.$row->id.') == $expected->{id} of ('.$expected->{id}.')';

        is $each->count, $expected->{count},
          'Got $each->count of ('.$each->count.') == $expected->{count} of ('.$expected->{count}.')';

        is $each->index, $expected->{index},
          'Got $each->index of ('.$each->index.') == $expected->{index} of ('.$expected->{index}.')';

        is $each->is_first, $expected->{first},
          'Got $each->first of ('.$each->is_first.') == $expected->{first} of ('.$expected->{first}.')';

        is $each->is_even, $expected->{even},
          'Got $each->even of ('.$each->is_even.') == $expected->{even} of ('.$expected->{even}.')';

        is $each->is_odd, $expected->{odd},
          'Got $each->odd of ('.$each->is_odd.') == $expected->{odd} of ('.$expected->{odd}.')';

      });
}

{
    my @expected = (
      { id=>2, count=>1, index=>0, first=>1, even=>0, odd=>1 },
      { id=>3, count=>2, index=>1, first=>0, even=>1, odd=>0 },
      { id=>4, count=>3, index=>2, first=>0, even=>0, odd=>1 },
      { id=>5, count=>4, index=>3, first=>0, even=>1, odd=>0 },
    );

    ok $schema
      ->resultset('Foo')
      ->each(sub {
        my ($each, $row) = @_;
        my $expected = { id=>1, count=>1, index=>0, first=>1, even=>0, odd=>1 };

        is $row->id, $expected->{id},
          'Got $row->id of ('.$row->id.') == $expected->{id} of ('.$expected->{id}.')';

        is $each->count, $expected->{count},
          'Got $each->count of ('.$each->count.') == $expected->{count} of ('.$expected->{count}.')';

        is $each->index, $expected->{index},
          'Got $each->index of ('.$each->index.') == $expected->{index} of ('.$expected->{index}.')';

        is $each->is_first, $expected->{first},
          'Got $each->first of ('.$each->is_first.') == $expected->{first} of ('.$expected->{first}.')';

        is $each->is_even, $expected->{even},
          'Got $each->even of ('.$each->is_even.') == $expected->{even} of ('.$expected->{even}.')';

        is $each->is_odd, $expected->{odd},
          'Got $each->odd of ('.$each->is_odd.') == $expected->{odd} of ('.$expected->{odd}.')';

        $each->escape;
      })
      ->each(sub {
        my ($each, $row) = @_;
        my $expected = shift @expected;

        is $row->id, $expected->{id},
          'Got $row->id of ('.$row->id.') == $expected->{id} of ('.$expected->{id}.')';

        is $each->count, $expected->{count},
          'Got $each->count of ('.$each->count.') == $expected->{count} of ('.$expected->{count}.')';

        is $each->index, $expected->{index},
          'Got $each->index of ('.$each->index.') == $expected->{index} of ('.$expected->{index}.')';

        is $each->is_first, $expected->{first},
          'Got $each->first of ('.$each->is_first.') == $expected->{first} of ('.$expected->{first}.')';

        is $each->is_even, $expected->{even},
          'Got $each->even of ('.$each->is_even.') == $expected->{even} of ('.$expected->{even}.')';

        is $each->is_odd, $expected->{odd},
          'Got $each->odd of ('.$each->is_odd.') == $expected->{odd} of ('.$expected->{odd}.')';
      })
      ->each(
        sub {
          fail 'should not see this';
        }, sub {
          pass 'got a proper fail';
        }
      );
}

{
    my @expected = (
      { id=>1, count=>1, index=>0, first=>1, even=>0, odd=>1 },
      { id=>2, count=>2, index=>1, first=>0, even=>1, odd=>0 },
      { id=>3, count=>3, index=>2, first=>0, even=>0, odd=>1 },
      { id=>4, count=>4, index=>3, first=>0, even=>1, odd=>0 },
      { id=>5, count=>5, index=>4, first=>0, even=>0, odd=>1 },
    );

    ok $schema
      ->resultset('Foo')
      ->each(sub {
        my ($each, $row) = @_;
        my $expected = shift @expected;

        $each
          ->first(sub {
            ok $expected->{first}, 'Got First as expected';
          })
          ->not_first(sub {
            ok !$expected->{first}, 'Got Not First as expected';
          })
          ->odd(sub {
            ok $expected->{odd}, 'Got Odd as expected';
          })
          ->even(sub {
            ok $expected->{even}, 'Got Even as expected';
          });

      });
}

done_testing;

