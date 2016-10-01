#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Gnarly')->no_columns->search(undef, {
   result_class => '::HRI',
});

{
   local $SIG{__WARN__} = sub {
      warn @_
         unless $_[0] =~ /ResultSets with an empty selection are deprecated/;
   };

   cmp_deeply([$rs->all], [ { }, { }, { } ], 'no columns selected');
}

done_testing;
