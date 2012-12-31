#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;
use JSYNC;
use DBIx::Class::Helper::Schema::Serialize;
use aliased 'DBIx::Class::Helper::Schema::Serialize::Result';
use Devel::Dwarn;

use TestSchema;

my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

DBIx::Class::Helper::Schema::Serialize->new(
   schema => $schema,
   starting_points => [ $schema->resultset('Gnarly_Station')->search_rs ],
   source_serializers => {
      Gnarly_Station => Result->new(
         relationships => ['gnarly'],
         include_relationships => 0,
      )->$Dwarn,
   },
)->serialize->$Dwarn;

ok 1;
done_testing;
