package DBIx::Class::Helper::ResultSet::Shortcut::Page;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub page { shift->search(undef, { page => shift }) }

1;
