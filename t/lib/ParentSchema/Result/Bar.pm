package ParentSchema::Result::Bar;

use DBIx::Class::Candy;

table 'Bar';

column id => {
   data_type => 'integer',
   size => 12,
};

column foo_id => {
   keep_storage_value => 1,
};

primary_key 'id';

belongs_to foo => 'ParentSchema::Result::Foo', 'foo_id';
has_many  foos => 'ParentSchema::Result::Foo', 'bar_id';

1;
