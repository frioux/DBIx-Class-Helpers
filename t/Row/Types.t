#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Typed');

cmp_deeply $rs->result_source->column_info('id'),
  {
    data_type         => 'serial',
    is_auto_increment => 1,
    is_numeric        => 1,
    isa               => isa('Type::Tiny'),
  },
  'id';

cmp_deeply $rs->result_source->column_info('serial_number'), {
    data_type  => 'varchar',
    size       => 32,
    is_numeric => 1,                   # overridden
    isa        => isa('Type::Tiny'),
  },
  'serial_number';

done_testing;
