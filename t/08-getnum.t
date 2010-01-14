#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $b_obj = B::svref_2object(\$value);  # for round trip problem
        my $flags = $b_obj->FLAGS;
            if ( (    $flags & B::SVf_IOK or $flags & B::SVp_IOK
                   or $flags & B::SVf_NOK or $flags & B::SVp_NOK
                 ) and !($flags & B::SVf_POK )
            );


done_testing;
