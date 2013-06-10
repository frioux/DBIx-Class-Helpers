package DBIx::Class::Helper::ResultSet::Shortcut::Prefetch;

use strict;
use warnings;

sub prefetch { return shift->search(undef, { prefetch => shift }) }

1;
