package DBIx::Class::Helper::ResultSet::Shortcut::RemoveColumns;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::RemoveColumns');

sub remove_columns { shift->search(undef, { remove_columns => shift }) }

1;
