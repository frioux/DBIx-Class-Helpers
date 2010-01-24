package TestSchema::Result::Gnarly;
use parent 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components(qw{Helper::Row::ToJSON Core});

__PACKAGE__->table('Gnarly');

__PACKAGE__->add_columns(qw/ id name /);

__PACKAGE__->add_columns(
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
