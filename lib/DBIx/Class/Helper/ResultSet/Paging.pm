package DBIx::Class::Helper::ResultSet::Paging;

use strict;
use warnings;

# VERSION

use base qw(
  DBIx::Class::Helper::ResultSet::Shortcut::Rows
  DBIx::Class::Helper::ResultSet::Shortcut::Page
);

sub paging {
  my ( $self, $page, $rows ) = @_;
  return $self->page($page)->rows($rows);
}

1;
