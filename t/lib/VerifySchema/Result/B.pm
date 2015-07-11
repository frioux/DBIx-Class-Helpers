package VerifySchema::Result::B;

use DBIx::Class::Candy -base => 'DBIx::Class::Core';

table 'B';

column id => {
   data_type => 'integer',
   size => 12,
};

primary_key 'id';

1;
