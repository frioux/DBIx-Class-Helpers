package DBIx::Class::Helper::ResultSet::Shortcut::GroupBy;

use strict;
use warnings;

# VERSION

sub group_by { shift->search(undef, { group_by => shift }) }

1;
