package TestSchema::Result::Foo;

use strict;
use warnings;

use parent 'ParentSchema::Result::Foo';

__PACKAGE__->load_components(qw{Helper::Row::SubClass Core});

__PACKAGE__->subclass;

1;
