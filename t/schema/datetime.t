use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;

TestSchema->load_components('Helper::Schema::DateTime');
my $schema = TestSchema->deploy_or_connect();

isa_ok($schema->datetime_parser, 'DateTime::Format::SQLite');

done_testing;
