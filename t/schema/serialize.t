#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;
use JSYNC;

use TestSchema;

subtest 'fk_check_source_auto' => sub {
   my $schema = TestSchema->deploy_or_connect();
   $schema->prepopulate;

   use Devel::Dwarn;
   warn JSYNC::dump(DwarnS $schema->serialize({
      starting_points => [
         map $schema->resultset($_)->search_rs, 'Gnarly_Station'
      ],
   }));
};

done_testing;
