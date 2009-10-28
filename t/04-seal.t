#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Test::More;

use TestSchema;

sub foo {
   my $art_rs = $schema->resultset('Artist');
   my $art2_rs = $art_rs->search({'cds.title' => { LIKE => 'a%' }}, {join => 'cds'});

   my $art3_rs = $art2_rs->seal();

   my $art4_rs = $art3_rs->search({'cds.title' => { LIKE => '%a' }}, {join => 'cds'});

   is($art4_rs->count, 0);
}
done_testing;
