package TestSchema::Result::Bar;

use strict;
use warnings;

our @events;

use parent 'ParentSchema::Result::Bar';

__PACKAGE__->load_components(qw{
   Helper::Row::ToJSON
   Helper::Row::SubClass
   Helper::Row::OnColumnChange
});

__PACKAGE__->subclass;

TestSchema::Result::Bar->before_column_change(
   foo_id => {
      method => 'before_foo_id',
   },
);

sub before_foo_id { push @events, [before_foo_id => $_[1], $_[2]] }

1;
