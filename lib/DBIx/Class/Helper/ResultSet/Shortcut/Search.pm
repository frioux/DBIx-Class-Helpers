package DBIx::Class::Helper::ResultSet::Shortcut::Search;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(
   Helper::ResultSet::Shortcut::Search::Null
   Helper::ResultSet::Shortcut::Search::NotNull
   Helper::ResultSet::Shortcut::Search::Like
   Helper::ResultSet::Shortcut::Search::NotLike
));

1;
