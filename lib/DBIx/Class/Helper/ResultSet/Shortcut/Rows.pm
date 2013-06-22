package DBIx::Class::Helper::ResultSet::Shortcut::Rows;

use strict;
use warnings;

# VERSION

sub rows { shift->search(undef, { rows => shift }) }

sub has_rows { return shift->rows(1)->next }

sub limit { return shift->rows(@_) }

1;
