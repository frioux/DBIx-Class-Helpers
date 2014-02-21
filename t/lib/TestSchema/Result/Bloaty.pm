package TestSchema::Result::Bloaty;

use DBIx::Class::Candy -components => [
   'Helper::Row::ProxyResultSetUpdate'
];

table 'Bloaty';

primary_column id => { data_type => 'int' };

column name => {
   data_type => 'varchar',
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

1;
