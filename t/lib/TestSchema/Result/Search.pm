package TestSchema::Result::Search;

use DBIx::Class::Candy;

table 'Search';

primary_column id => { data_type => 'int' };
column name => { data_type => 'varchar' };

1;
