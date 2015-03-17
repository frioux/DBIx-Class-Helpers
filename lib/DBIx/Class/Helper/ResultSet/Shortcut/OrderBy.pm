package DBIx::Class::Helper::ResultSet::Shortcut::OrderBy;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub order_by { shift->search(undef, { order_by => shift }) }

1;
