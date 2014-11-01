#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal;

use TestSchema;

my $schema = TestSchema->deploy_or_connect();

like(
   exception { $schema->resultset('foo_Bar') },
   qr/\* Foo_Bar <--/,
   'found correct RS',
);

done_testing;
