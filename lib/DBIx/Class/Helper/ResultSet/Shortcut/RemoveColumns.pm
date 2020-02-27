package DBIx::Class::Helper::ResultSet::Shortcut::RemoveColumns;

use strict;
use warnings;

sub remove_columns { shift->search(undef, { remove_columns => shift }) }

1;
