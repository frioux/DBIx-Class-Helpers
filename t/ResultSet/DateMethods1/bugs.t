#!perl

use strict;
use warnings;
use lib 't/lib';

use DateTime;
use Test::More;
use TestSchema;

use Test::Fatal 'lives_ok';

my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

lives_ok {
   $schema->resultset('HasDateOps')
      ->dt_before(DateTime->now, { -ident => '.a_date' })
      ->delete;
} 'does not explode due to spurious qualifier';

done_testing;
