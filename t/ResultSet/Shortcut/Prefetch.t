#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Foo');

cmp_deeply
   [$rs->prefetch('bar')->all],
   [$rs->search(undef,{prefetch => 'bar' })->all],
   'prefetch works the same with scalar';

cmp_deeply
   [$rs->prefetch(['bar','bars'])->all],
   [$rs->search(undef,{prefetch => ['bar','bars'] })->all],
   'prefetch works the same with arrayref';

cmp_deeply
   [$rs->prefetch('bar','bars')->all],
   [$rs->search(undef,{prefetch => ['bar','bars'] })->all],
   'prefetch works the same with list';

done_testing;
