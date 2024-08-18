package DBIx::Class::Helper::ResultSet::Shortcut::Prefetch;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub prefetch { return shift->search(undef, { prefetch => @_ > 1 ? \@_ : shift }) }

1;
