#!/usr/bin/env perl

use strict;
use warnings;

use lib 't/lib';
use Test::More (tests => 2);
use Devel::Dwarn; $Data::Dumper::Maxdepth = 4;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();

my $q_gnarly = $schema->resultset('Gnarly')
    ->search(undef, { columns => [ qw(id) ], group_by => [ qw(id) ] })
    ->count_rs
    ->as_query;
ok(${ $q_gnarly }->[0] !~ /"me"\."id", "me"\."id"/);
my $q_bloaty = $schema->resultset('Bloaty')
    ->search(undef, { columns => [ qw(id) ], group_by => [ qw(id) ] })
    ->count_rs
    ->as_query;
ok(${ $q_bloaty }->[0] !~ /"me"\."id", "me"\."id"/);
