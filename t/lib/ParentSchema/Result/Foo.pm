package ParentSchema::Result::Foo;
use parent 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components('Core');

__PACKAGE__->table('Foo');

__PACKAGE__->add_columns(
   id => {
      is_numeric => 1,
   },
   bar_id => {
      data_type => 'integer'
   },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( bar =>  'ParentSchema::Result::Bar', 'bar_id' );
__PACKAGE__->has_many(   bars => 'ParentSchema::Result::Bar', 'foo_id' );

1;
