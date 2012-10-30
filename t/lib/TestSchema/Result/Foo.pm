package TestSchema::Result::Foo;

use DBIx::Class::Candy -base => 'ParentSchema::Result::Foo',
   -components => [qw(
          Helper::Row::NumifyGet
          Helper::Row::SubClass
          Helper::Row::OnColumnChange
       )];

subclass;

1;
