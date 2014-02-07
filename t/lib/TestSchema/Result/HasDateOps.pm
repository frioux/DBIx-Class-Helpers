package TestSchema::Result::HasDateOps;

use DBIx::Class::Candy;

table 'HasDateOps';

column 'id';
column a_date => { data_type => 'datetime' };
column b_date => {
   data_type => 'datetime',
   is_nullable => 1,
};

primary_key 'id';

1;
