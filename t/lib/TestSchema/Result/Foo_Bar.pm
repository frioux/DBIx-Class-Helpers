package TestSchema::Result::Foo_Bar;

use DBIx::Class::Candy
   -components => [
      'Helper::Row::JoinTable',
      'Helper::Row::SelfResultSet',
   ];

join_table({
   left_class   => 'Foo',
   right_class  => 'Bar',
   right_method => 'bar',
});

1;
