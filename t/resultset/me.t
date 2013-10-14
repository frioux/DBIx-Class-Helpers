#!perl

use lib 't/lib';
use Test::Roo;
with 'A::Does::TestSchema';
sub no_deploy {}

test basic => sub {
   my $schema = shift->schema;

   my $rs = $schema->resultset('Gnarly');
   my $alias = $rs->current_source_alias;

   is $rs->me, "$alias.", 'me without args';
   is $rs->me('col'), "$alias.col", 'me with args';
};

run_me;
done_testing;
