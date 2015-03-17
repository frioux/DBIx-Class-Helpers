package DBIx::Class::Helper::ResultSet::Shortcut::Rows;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub rows { shift->search(undef, { rows => shift }) }

1;
