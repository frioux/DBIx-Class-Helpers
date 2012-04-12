use strict;
use warnings;

use lib 't/lib';
use Test::More;

use TestSchema;

TestSchema->load_components('Helper::Schema::GenerateSource');
TestSchema->generate_source(PsychoKiller => 'Lolbot');

my $class = TestSchema->class('PsychoKiller');
ok($class, 'PsychoKiller gets registered');
ok($class->isa('Lolbot'), 'PsychoKiller inherits from Lolbot');
ok(ref($class) ne 'Lolbot', '... but PsychoKiller is not just a Lolbot');

done_testing;
