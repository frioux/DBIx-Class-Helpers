#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test::More;
use Test::Exception;

use DBIx::Class::Helpers::Util ':all';

my ($ns, $class) = get_namespace_parts('Project::Schema::Result::Child');
is $ns, 'Project::Schema::Result',
   'namespace part of get_namespace_parts works';
is $class, 'Child', 'result part of get_namespace_parts works';

assert_load_namespaces: {
   ok assert_load_namespaces('P::Result::Foo', 'L::Result::Bar'),
      'assert_load_namespaces works when true';
   ok !assert_load_namespaces('P::Foo', 'L::Result::Bar'),
      'assert_load_namespaces works when left is false';
   ok !assert_load_namespaces('P::Result::Foo', 'L::Bar'),
      'assert_load_namespaces works when right is false';
   ok !assert_load_namespaces('P::Foo', 'L::Bar'),
      'assert_load_namespaces works when both are false';
}

assert_not_load_namespaces: {
   ok assert_not_load_namespaces('P::Foo', 'L::Bar'),
      'assert_not_load_namespaces works true';
   ok !assert_not_load_namespaces('P::Result::Foo', 'L::Result::Bar'),
      'assert_not_load_namespaces works when both false';
   ok !assert_not_load_namespaces('P::Foo', 'L::Result::Bar'),
      'assert_not_load_namespaces works when right is false';
   ok !assert_not_load_namespaces('P::Result::Foo', 'L::Bar'),
      'assert_not_load_namespaces works when left is false';
}

assert_similar_namespaces: {
   lives_ok { assert_similar_namespaces('P::Foo', 'L::Bar') }
      'assert_similar_namespaces works when both non-namespace';
   lives_ok { assert_similar_namespaces('P::Result::Foo', 'L::Result::Bar') }
      'assert_similar_namespaces works when both namespace';
   dies_ok { assert_similar_namespaces('P::Foo', 'L::Result::Bar') }
      'assert_similar_namespaces works when right is namespace';
   dies_ok { assert_similar_namespaces('P::Result::Foo', 'L::Bar') }
      'assert_similar_namespaces works when left is namespace';
}

done_testing;
