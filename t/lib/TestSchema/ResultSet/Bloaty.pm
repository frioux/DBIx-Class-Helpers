package TestSchema::ResultSet::Bloaty;
use strict;
use warnings;

use parent 'TestSchema::ResultSet';

__PACKAGE__->load_components(qw{
   Helper::ResultSet::AutoRemoveColumns
});

1;
