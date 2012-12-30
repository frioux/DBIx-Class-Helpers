#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;
use JSYNC;
use DBIx::Class::Helper::Schema::Serialize;
use Devel::Dwarn;

use TestSchema;

my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

DBIx::Class::Helper::Schema::Serialize->new(
   schema => $schema,
   starting_points => [
      map $schema->resultset($_)->search_rs, 'Gnarly_Station'
   ],
)->serialize->$Dwarn;

ok 1;
done_testing;
