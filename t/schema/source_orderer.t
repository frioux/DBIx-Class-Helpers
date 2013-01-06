#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;
use DBIx::Class::Helper::Schema::SourceOrderer;
use Devel::Dwarn;

use TestSchema;

my $schema = TestSchema->deploy_or_connect();

DBIx::Class::Helper::Schema::SourceOrderer->new(
   schema => $schema,
)->source_tree->$Dwarn;

ok 1;
done_testing;
