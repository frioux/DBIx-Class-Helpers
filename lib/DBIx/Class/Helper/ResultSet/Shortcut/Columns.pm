package DBIx::Class::Helper::ResultSet::Shortcut::Columns;

use strict;
use warnings;

sub columns { shift->search(undef, { columns => shift }) }

1;
