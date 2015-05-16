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

cmp_deeply ['fizz', 'bizz'], [$rs->_helper_unwrap_columns('fizz', 'bizz')], 'unwrap array';
cmp_deeply ['fizz', 'bizz'], [$rs->_helper_unwrap_columns(['fizz', 'bizz'])], 'unwrap arrayref';

is $rs->_helper_meify('id'), 'id', 'not meifying';
is $rs->_helper_meify('.id'), 'me.id', 'meifying';

done_testing;
