#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;

use TestSchema;
use B;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

# stolen from JSON::PP
sub is_numeric {
   my $value = shift;
   my $b_obj = B::svref_2object(\$value);
   my $flags = $b_obj->FLAGS;
   ok( ((    $flags & B::SVf_IOK or $flags & B::SVp_IOK
          or $flags & B::SVf_NOK or $flags & B::SVp_NOK
        ) and !($flags & B::SVf_POK )), "id $value has been 'numified'"
   );
}

for (map $_->id, $schema->resultset('Foo')->all) {
   is_numeric($_);
}

for (map +{$_->get_columns}, $schema->resultset('Foo')->all) {
   is_numeric($_->{id});
}

for (map +{$_->get_inflated_columns}, $schema->resultset('Foo')->all) {
   is_numeric($_->{id});
}

done_testing;
