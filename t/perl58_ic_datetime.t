#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use DateTime;
use TestSchema;

my $schema = TestSchema->deploy_or_connect();

my $rs = $schema->resultset('ICDateTime');

my $row = $rs->create( { id => 1, datetime => DateTime->now() } );

isa_ok $row->datetime, "DateTime";

$row = $rs->find(1);

isa_ok $row->datetime, "DateTime";

cmp_deeply(
    $rs->result_source->column_info('datetime'),
    {
        _ic_dt_method => 'datetime',
        _inflate_info => {
            deflate => ignore(),
            inflate => ignore(),
        },
        data_type => 'datetime',
    },
    "Check result_source->column_info(datetime)"
);

done_testing;
