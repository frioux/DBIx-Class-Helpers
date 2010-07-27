package TestSchema::Result::Bar;

use strict;
use warnings;

use parent 'ParentSchema::Result::Bar';

__PACKAGE__->load_components(qw{
   Helper::Row::ToJSON
   Helper::Row::SubClass
   Helper::Row::ColumnDelta
});

__PACKAGE__->subclass;

1;
