package ParentSchema::Result::Bar;
use parent 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components('Core');

__PACKAGE__->table('Bar');

__PACKAGE__->add_columns(id => {
      data_type => 'integer',
      size => 12,
   }, qw/foo_id /
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( foo => 'ParentSchema::Result::Foo', 'foo_id' );

1;
