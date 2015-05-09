use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

is(exception {
   TSchema->$_('TPassResult', 'TPassResultSet') for TSchema->result_verifiers;
}, undef, 'Result and Set are fine');

like(exception {
   TSchema->$_('TFailResult', 'TPassResultSet') for TSchema->result_verifiers;
}, qr/^TFailResult is not a Herp/, 'Result fails');

like(exception {
   TSchema->$_('TPassResult', 'TFailResultSet') for TSchema->result_verifiers;
}, qr/^TFailResultSet is not a Derp/, 'ResultSet fails');

done_testing;

BEGIN {
   package TSchema;

   use base 'DBIx::Class::Helper::Schema::Verifier::Parent';

   sub base_result    { 'Herp' }
   sub base_resultset { 'Derp' }

   package Herp;
   use Moo;
   package Derp;
   use Moo;

   package TPassResult;

   use base 'Herp';

   package TPassResultSet;

   use base 'Derp';

   package TFailResult;
   use Moo;
   package TFailResultSet;
   use Moo;
}

