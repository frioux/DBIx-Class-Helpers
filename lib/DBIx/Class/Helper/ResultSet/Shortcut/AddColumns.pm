package DBIx::Class::Helper::ResultSet::Shortcut::AddColumns;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub add_columns { shift->search(undef, { '+columns' => shift }) }

1;
