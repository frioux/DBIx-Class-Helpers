package TestSchema::Result::Bloaty;

use DBIx::Class::Candy;

table 'Bloaty';

column 'id';

column name => {
   remove_column => 1,
};

column literature => {
   data_type => 'text',
   is_nullable => 1,
};

column your_mom => {
   data_type => 'blob',
   is_nullable => 1,
   is_serializable => 1,
};

primary_key 'id';

1;
