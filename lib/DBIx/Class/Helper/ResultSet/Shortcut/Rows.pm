package DBIx::Class::Helper::ResultSet::Shortcut::Rows;

use strict;
use warnings;

# VERSION

sub rows { shift->search(undef, { rows => shift }) }

1;
