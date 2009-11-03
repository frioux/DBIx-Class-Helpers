package TestSchema::ResultSet::Foo;
use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::VirtualView');

1;
