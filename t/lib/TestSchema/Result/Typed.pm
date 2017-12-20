package TestSchema::Result::Typed;

use DBIx::Class::Candy -components => [
    qw(
      Helper::Row::Types
      )
];

use Types::SQL -types;

table 'Typed';

primary_column id => { isa => Serial };

column serial_number => { isa => Varchar [32], is_numeric => 1 };

1;
