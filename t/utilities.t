#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal qw( lives_ok dies_ok );;
use Test::Deep;

use DBIx::Class::Helpers::Util ':all';

my ($ns, $class) = get_namespace_parts('Project::Schema::Result::Child');
is $ns, 'Project::Schema::Result',
   'namespace part of get_namespace_parts works';
is $class, 'Child', 'result part of get_namespace_parts works';

($ns, $class) = get_namespace_parts('Project::Schema::Result::HouseHold::Child');
is $ns, 'Project::Schema::Result',
   'namespace part of get_namespace_parts works';
is $class, 'HouseHold::Child', 'result part of get_namespace_parts works';

subtest is_load_namespaces => sub {
   ok is_load_namespaces('P::Result::Foo'),
      'is_load_namespaces works when correct';
   ok !is_load_namespaces('P::Foo'),
      'is_load_namespaces works when incorrect';
   ok is_load_namespaces('P::Result::Foo::Bar'),
         'is_load_namespaces works with two levels namespace';
};

subtest is_not_load_namespaces => sub {
   ok is_not_load_namespaces('P::Foo'),
      'is_not_load_namespaces works correct';
   ok !is_not_load_namespaces('P::Result::Foo'),
      'is_not_load_namespaces works when incorrect';
};

subtest assert_similar_namespaces => sub {
   lives_ok { assert_similar_namespaces('P::Foo', 'L::Bar') }
      'assert_similar_namespaces works when both non-namespace';
   lives_ok { assert_similar_namespaces('P::Result::Foo', 'L::Result::Bar') }
      'assert_similar_namespaces works when both namespace';
   dies_ok { assert_similar_namespaces('P::Foo', 'L::Result::Bar') }
      'assert_similar_namespaces works when right is namespace';
   dies_ok { assert_similar_namespaces('P::Result::Foo', 'L::Bar') }
      'assert_similar_namespaces works when left is namespace';
   lives_ok { assert_similar_namespaces('P::Result::Foo::Bar',  'L::Result::Foo::Bar')}
      'assert_similar_namespaces works with two levels of right namespace';
};

subtest order_by_vistor => sub {
   my $complex_order_by = [
      { -desc => [qw( foo bar )] },
      'baz',
      { -asc => 'biff' }
   ];

   cmp_deeply(
      order_by_visitor($complex_order_by, sub{shift}),
      $complex_order_by,
      'roundtrip'
   );

   cmp_deeply(
      order_by_visitor('frew', sub{'bar'}),
      'bar',
      'simplest ever'
   );

   cmp_deeply(
      order_by_visitor({ -asc => 'foo' }, sub{'bar'}),
      { -asc => 'bar' },
      'simple hash'
   );

   cmp_deeply(
      order_by_visitor([{ -asc => 'foo' }, 'bar'], sub{
         if ($_[0] eq 'foo') {
            return 'foot'
         } else {
            return $_[0]
         }
      }),
      [{ -asc => 'foot' }, 'bar'],
      'typical'
   );

};

subtest normalize_connect_info => sub {
   subtest 'form 1' => sub {
      cmp_deeply(
         normalize_connect_info('dbi:foo'),
         { dsn => 'dbi:foo' },
         'dsn',
      );

      cmp_deeply(
         normalize_connect_info('dbi:foo', 'user'),
         {
            dsn => 'dbi:foo',
            user => 'user',
         },
         'dsn, user',
      );
      cmp_deeply(
         normalize_connect_info('dbi:foo', 'user', 'pass'),
         {
            dsn => 'dbi:foo',
            user => 'user',
            password => 'pass',
         },
         'dsn, user, pass',
      );
      cmp_deeply(
         normalize_connect_info('dbi:foo', 'user', 'pass',
            { LongReadLen => 1 },
         ),
         {
            dsn => 'dbi:foo',
            user => 'user',
            password => 'pass',
            LongReadLen => 1,
         },
         'dsn, user, pass, dbi_opts',
      );
      cmp_deeply(
         normalize_connect_info('dbi:foo', 'user', 'pass',
            { LongReadLen => 1 },
            { quote_names => 1 },
         ),
         {
            dsn => 'dbi:foo',
            user => 'user',
            password => 'pass',
            LongReadLen => 1,
            quote_names => 1,
         },
         'all params',
      );
   };

   subtest 'form 2' => sub {
      my $s = sub {};
      cmp_deeply(
         normalize_connect_info($s),
         { dbh_maker => $s },
         'just sub',
      );

      cmp_deeply(
         normalize_connect_info($s, { quote_names => 1 }),
         { dbh_maker => $s, quote_names => 1 },
         'sub and options',
      );
   };

};

done_testing;
