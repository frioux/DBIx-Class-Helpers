package DBIx::Class::Helper::ResultSet::Shortcut::Page;

use strict;
use warnings;

sub page { shift->search(undef, { page => shift }) }

1;
