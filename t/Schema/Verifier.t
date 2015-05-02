use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

like(exception {
   require VerifySchema;
}, qr/^Derp/, 'Schema verify checks all input');

use aliased 'DBIx::Class::Helper::Schema::Verifier::C3';

subtest C3 => sub {

   is(exception {
      C3->$_('Cat', 'Cat') for C3->result_verifiers;
   }, undef, 'Result and Set are fine');

   like(exception {
      C3->$_('Foo', 'Cat') for C3->result_verifiers;
   }, qr/^Foo does not use c3, it uses dfs/, 'Result fails');

   like(exception {
      C3->$_('Cat', 'Bar') for C3->result_verifiers;
   }, qr/^Bar does not use c3, it uses dfs/, 'ResultSet fails');
};

done_testing;

BEGIN {
   package Foo;

   use base 'DBIx::Class::Core';

   package Bar;

   use base 'DBIx::Class::ResultSet';

   package Cat;
   use MRO::Compat;
   use mro 'c3';
   use base 'DBIx::Class';
}
