#!perl

use lib 't/lib';
use Test::Deep 'cmp_deeply';
use Test::Roo;
with 'A::Does::TestSchema';

test basic => sub {
   my $schema = shift->schema;

   my $rs = $schema->resultset('Gnarly')->no_columns->search(undef, {
      result_class => '::HRI',
   });

   cmp_deeply([$rs->all], [ { }, { }, { } ], 'no columns selected');
};

run_me;
done_testing;
