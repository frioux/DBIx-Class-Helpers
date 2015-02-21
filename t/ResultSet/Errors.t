#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();

like exception {
   $schema->resultset('Gnarly')->literature
}, qr{^\QYou're trying to call a Result ("TestSchema::Result::Gnarly") method ("literature") on a ResultSet ("TestSchema::ResultSet::Gnarly") at t/ResultSet/Errors.t line 14.\E}, 'exceptional';

done_testing;

