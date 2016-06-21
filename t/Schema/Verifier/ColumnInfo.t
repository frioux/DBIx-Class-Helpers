use strict; use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

is(exception {
   TSchema->$_('TPassResult', 'Set') for TSchema->result_verifiers;
}, undef, 'Standard keys are allowed');

my $e = exception {
   TSchema->$_('TFailResult1', 'Set') for TSchema->result_verifiers;
};
like $e, qr/^Forbidden column config/, 'Forbidden keys fail verification';
like $e, qr/bad1/, 'Failed column mentioned';
like $e, qr/unallowed_key/, 'Bad key mentioned';
like $e, qr/TFailResult1/, 'Failing class mentioned';

is(exception {
   TSchema->$_('TPassResultExtended', 'Set') for TSchema->result_verifiers;
}, undef, 'Extended allow list works');

done_testing;

BEGIN {
   package TSchema;

   use base 'DBIx::Class::Helper::Schema::Verifier::ColumnInfo';

   sub allowed_column_keys {
      my @list = $_[0]->next::method;
      push @list, 'you_should_allow_this';
      @list
   }

   package TPassResult;
   sub columns_info {
      # all the default keys
      {
         thing => {
            accessor => 1,
            data_type => 1,
            size => 1,
            is_nullable => 1,
            is_auto_increment => 1,
            is_numeric => 1,
            is_foreign_key => 1,
            default_value => 1,
            sequence => 1,
            retrieve_on_insert => 1,
            auto_nextval => 1,
            extra => {
               extra_keys => 1,
            },
         },
      }
   }
   package TFailResult1;
   sub columns_info {
      {
         bad1 => {
            unallowed_key => 1,
         },
      }
   }
   package TPassResultExtended;
   sub columns_info {
      {
         bad2 => {
            you_should_allow_this => 1,
         }
      }
   }
   package Set;
}

