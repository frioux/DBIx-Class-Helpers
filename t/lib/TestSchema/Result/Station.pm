package TestSchema::Result::Station;

use DBIx::Class::Candy;

table 'Station';

column 'id';
column 'name';

primary_key 'id';

1;
