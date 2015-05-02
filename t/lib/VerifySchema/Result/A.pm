package VerifySchema::Result::A;

use DBIx::Class::Candy -base => 'DBIx::Class::Core';

table 'A';

column id => {
   data_type => 'integer',
   size => 12,
};

primary_key 'id';

1;
