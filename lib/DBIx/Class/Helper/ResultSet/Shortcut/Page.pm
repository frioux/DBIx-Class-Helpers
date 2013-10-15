package DBIx::Class::Helper::ResultSet::Shortcut::Page;

use strict;
use warnings;

# VERSION

sub page { shift->search(undef, { page => shift }) }

1;
