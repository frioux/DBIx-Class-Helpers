package DBIx::Class::Helper::ResultSet::Shortcut::HasRows;

use strict;
use warnings;

use base 'DBIx::Class::Helper::ResultSet::Shortcut::Rows';

# VERSION

sub has_rows { !! shift->rows(1)->next }

1;
