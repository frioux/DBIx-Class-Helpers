package TestSchema::Result::Bar;

use DBIx::Class::Candy
   -base => 'ParentSchema::Result::Bar',
   -components => [qw(
      Helper::Row::ToJSON
      Helper::Row::SubClass
      Helper::Row::OnColumnChange
      Helper::Row::SelfResultSet
      Helper::Row::CleanResultSet
    )];

our @events;

subclass;

before_column_change(foo_id => {
   method => 'before_foo_id',
});


sub before_foo_id { push @events, [before_foo_id => $_[1], $_[2]] }

1;
