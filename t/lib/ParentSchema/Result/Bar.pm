package ParentSchema::Result::Bar;

use DBIx::Class::Candy -base => 'ParentSchema::Result';

table 'Bar';

column id => {
   data_type => 'integer',
   size => 12,
};

column foo_id => {
   data_type => 'integer',
   keep_storage_value => 1,
};

column test_flag => {
   keep_storage_value => 1,
   is_nullable => 1,
};

primary_key 'id';

belongs_to foo => '::Foo', 'foo_id';
has_many  foos => '::Foo', 'bar_id';

1;
