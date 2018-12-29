#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;
use Test::Fatal 'exception';

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs2 = $schema->resultset('Foo')->search({ id => { '>=' => 3 } });
my $rs3 = $schema->resultset('Foo')->search({ id => [ 1, 3 ] }, { alias => 'rs3' });

cmp_deeply [ sort map $_->id, $rs2->exists($rs3, { id => 'me.id' })->all ], [3],
   'exists returns correct values';

cmp_deeply [ sort map $_->id, $rs2->not_exists($rs3, { id => 'me.id' })->all ], [4,5],
   'not_exists returns correct values';

like exception { $rs2->exists($rs2)->all } => qr/without a join query doesn't make any sense/,
   'non-existent join query should throw exception';

like exception { $rs2->exists($rs2, {})->all } => qr/without a join query doesn't make any sense/,
   'empty join query should throw exception';

like exception { $rs2->exists($rs2, { id => 'me.id' })->all } => qr/specify an alias/,
   'exists with same alias throws exception';

done_testing;
