package TestSchema::Result::HasDateOps;

use DBIx::Class::Candy;

table 'HasDateOps';

primary_column id => { data_type => 'int' };;
column a_date => { data_type => 'datetime' };
column b_date => {
   data_type => 'datetime',
   is_nullable => 1,
};

1;
