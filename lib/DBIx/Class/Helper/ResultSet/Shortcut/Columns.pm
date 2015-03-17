package DBIx::Class::Helper::ResultSet::Shortcut::Columns;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub columns { shift->search(undef, { columns => shift }) }

1;
