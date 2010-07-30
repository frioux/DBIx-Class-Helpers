package TestSchema::Result::Foo;

use DBIx::Class::Candy -base => 'ParentSchema::Result::Foo',
   -components => [qw(Helper::Row::NumifyGet Helper::Row::SubClass)];

subclass;

1;
