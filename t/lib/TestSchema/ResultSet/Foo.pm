package TestSchema::ResultSet::Foo;
use strict;
use warnings;

use parent 'TestSchema::ResultSet';

__PACKAGE__->load_components(qw{ Helper::Random Helper::VirtualView });

1;
