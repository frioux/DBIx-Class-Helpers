package TestSchema::ResultSet::Bar;
use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::Seal');

1;
