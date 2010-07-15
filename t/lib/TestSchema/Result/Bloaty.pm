package TestSchema::Result::Bloaty;

use parent 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('Bloaty');

__PACKAGE__->add_columns(qw/ id /);

__PACKAGE__->add_columns(
   name => {
      remove_column => 1,
   },
   literature => {
      data_type => 'text',
      is_nullable => 1,
   },
   your_mom => {
      data_type => 'blob',
      is_nullable => 1,
      is_serializable => 1,
   },
);

__PACKAGE__->set_primary_key('id');


1;
