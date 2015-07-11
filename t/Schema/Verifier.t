use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

my $e = exception { require VerifySchema };
like($e, qr/^Derp: .*::A\b/m, 'Schema verify checks all input');
like($e, qr/^Herp: .*::A\b/m, 'Schema runs all checks per r/set');
like($e, qr/^Derp: .*::B\b/m, 'Schema verify checks all r/sets');

done_testing;
