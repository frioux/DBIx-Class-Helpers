package TestSchema::ResultSet::HasDateOps;
use strict;
use warnings;

use parent 'TestSchema::ResultSet';

__PACKAGE__->load_components(qw{
   Helper::ResultSet::DateMethods1
});

1;
