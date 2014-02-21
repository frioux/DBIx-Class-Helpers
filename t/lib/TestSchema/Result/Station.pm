package TestSchema::Result::Station;

use DBIx::Class::Candy;

table 'Station';

primary_column id => { data_type => 'int' };
column name => { data_type => 'varchar' };

1;
