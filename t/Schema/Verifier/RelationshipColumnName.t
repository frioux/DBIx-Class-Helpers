use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

is(exception {
   TSchema->$_('TPassResult', 'Set') for TSchema->result_verifiers;
}, undef, 'Result and Set are fine');

like(exception {
   TSchema->$_('TFailResult1', 'Set') for TSchema->result_verifiers;
}, qr/^TFailResult1 has a relationship name that is the same as a column name: a/, 'Result fails (single)');

like(exception {
   TSchema->$_('TFailResult2', 'Set') for TSchema->result_verifiers;
}, qr/^TFailResult2 has relationship names that are the same as column names: a b/, 'Result fails (plural)');

done_testing;

BEGIN {
   package TSchema;

   use base 'DBIx::Class::Helper::Schema::Verifier::RelationshipColumnName';

   package TPassResult;
   sub columns {
      qw(a b c)
   }
   sub relationships {
      qw(e f g)
   }
   package Set;
   package TFailResult1;
   sub columns {
      qw(a b c)
   }
   sub relationships {
      qw(a f g)
   }
   package TFailResult2;
   sub columns {
      qw(a b c)
   }
   sub relationships {
      qw(a b g)
   }
}

