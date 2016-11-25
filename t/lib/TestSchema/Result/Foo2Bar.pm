package TestSchema::Result::Foo2Bar;

use DBIx::Class::Candy
   -base => 'ParentSchema::Result::Bar',
   -components => [qw(
      Helper::Row::ToJSON
      Helper::Row::SubClass
      Helper::Row::OnColumnChange
      Helper::Row::SelfResultSet
      Helper::Row::CleanResultSet
    )];

__PACKAGE__->mk_group_accessors(inherited => 'on_column_change_allow_override_args');
our @events;

subclass;

__PACKAGE__->belongs_to('foo_id','TestSchema::Result::Foo','id');
1;
