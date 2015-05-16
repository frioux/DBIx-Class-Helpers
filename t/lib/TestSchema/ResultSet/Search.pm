package TestSchema::ResultSet::Search;
use strict;
use warnings;

# intentionally not using TestSchema::ResultSet
use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw{ Helper::ResultSet::Shortcut::Search });

1;
