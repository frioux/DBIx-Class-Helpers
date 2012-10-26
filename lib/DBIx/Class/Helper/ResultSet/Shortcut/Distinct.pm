package DBIx::Class::Helper::ResultSet::Shortcut::Distinct;

use strict;
use warnings;

sub distinct { $_[0]->search(undef, { distinct => defined $_[1] ? $_[1] : 1 }) }

1;
