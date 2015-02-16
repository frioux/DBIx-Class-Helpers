use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;
use DateTime;

TestSchema->load_components('Helper::Schema::DateTime');
my $schema = TestSchema->deploy_or_connect();

isa_ok($schema->datetime_parser, 'DateTime::Format::SQLite');
my $dt = DateTime->now;
my $s = $schema->format_datetime($dt);
is(
   $schema->format_datetime($schema->parse_datetime($s)),
   $schema->format_datetime($dt),
   'format_datetime and parse_datetime roundtrip',
);

done_testing;
