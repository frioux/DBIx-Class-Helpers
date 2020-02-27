package DBIx::Class::Helper::ResultSet::Shortcut::HasRows;

use strict;
use warnings;

use parent 'DBIx::Class::Helper::ResultSet::Shortcut::Rows';

sub has_rows { !! shift->rows(1)->next }

1;
