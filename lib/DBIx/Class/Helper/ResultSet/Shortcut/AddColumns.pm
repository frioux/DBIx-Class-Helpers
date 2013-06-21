package DBIx::Class::Helper::ResultSet::Shortcut::AddColumns;

use strict;
use warnings;

# VERSION

sub add_columns { shift->search(undef, { '+columns' => shift }) }

1;
