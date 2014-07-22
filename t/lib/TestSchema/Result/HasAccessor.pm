package TestSchema::Result::HasAccessor;

use DBIx::Class::Candy
   -components => [qw(
      Helper::Row::ToJSON
   )];


table 'HasAccessor';

primary_column id => { data_type => 'int' };;
column usable_column => { data_type => 'varchar' };
column unusable_column => {
   data_type => 'varchar',
   accessor => 'alternate_name',
};

1;
