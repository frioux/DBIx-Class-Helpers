package DBIx::Class::Helper::ResultSet::Shortcut::Limit;

use strict;
use warnings;

use base 'DBIx::Class::Helper::ResultSet::Shortcut::Rows';

# VERSION

sub limit { return shift->rows(@_) }

1;
