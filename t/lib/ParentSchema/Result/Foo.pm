package ParentSchema::Result::Foo;

use DBIx::Class::Candy;

table 'Foo';

column id => {
   data_type => 'integer',
   is_numeric => 1,
};

column bar_id => {
   data_type => 'integer'
};

primary_key 'id';

belongs_to bar =>  'ParentSchema::Result::Bar', 'bar_id',
{ is_foreign_key_constraint => 0 };
has_many   bars => 'ParentSchema::Result::Bar', 'foo_id';

1;
