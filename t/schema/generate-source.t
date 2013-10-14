#!perl

use lib 't/lib';
use Test::Roo;
use TestSchema;
sub schema { 'TestSchema' }

test basic => sub {
   my $schema = shift->schema;

   $schema->load_components('Helper::Schema::GenerateSource');
   $schema->generate_source(PsychoKiller => 'Lolbot');

   my $class = $schema->class('PsychoKiller');
   ok($class, 'PsychoKiller gets registered');
   ok($class->isa('Lolbot'), 'PsychoKiller inherits from Lolbot');
   ok(ref($class) ne 'Lolbot', '... but PsychoKiller is not just a Lolbot');
};

run_me;
done_testing;
