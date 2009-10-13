package ParentSchema::Result::Foo;
use parent 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components('Core');

__PACKAGE__->table('Foo');

__PACKAGE__->add_columns(qw/ id bar_id /);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( bar => 'ParentSchema::Result::Bar', 'bar_id' );

1;
