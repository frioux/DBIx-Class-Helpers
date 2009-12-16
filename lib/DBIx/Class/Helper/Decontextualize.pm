package DBIx::Class::Helper::Decontextualize;

use strict;
use warnings;

# ABSTRACT: Get rid of search context issues

sub search {
   shift->search_rs(@_);
}

1;
