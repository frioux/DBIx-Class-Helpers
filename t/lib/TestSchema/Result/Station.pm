package TestSchema::Result::Station;
use parent 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components('Core');

__PACKAGE__->table('Station');

__PACKAGE__->add_columns(qw/ id name /);

__PACKAGE__->set_primary_key('id');

1;
