use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

like(exception {
   require VerifySchema;
}, qr/^Derp/, 'Schema verify checks all input');

done_testing;
