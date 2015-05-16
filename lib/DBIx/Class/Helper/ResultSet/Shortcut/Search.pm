package DBIx::Class::Helper::ResultSet::Shortcut::Search;

use strict;
use warnings;

use parent (qw(
   DBIx::Class::Helper::ResultSet::Shortcut::Search::Null
   DBIx::Class::Helper::ResultSet::Shortcut::Search::NotNull
   DBIx::Class::Helper::ResultSet::Shortcut::Search::Like
   DBIx::Class::Helper::ResultSet::Shortcut::Search::NotLike
));

1;
