package DBIx::Class::Helper::ResultSet::Shortcut::HRI;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub hri {
   shift->search(undef, {
      result_class => 'DBIx::Class::ResultClass::HashRefInflator' })
}

1;
