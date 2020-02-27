package DBIx::Class::Helper::ResultSet::Shortcut::Rows;

use strict;
use warnings;

sub rows { shift->search(undef, { rows => shift }) }

1;
