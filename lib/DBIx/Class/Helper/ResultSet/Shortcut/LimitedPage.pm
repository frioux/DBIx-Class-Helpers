package DBIx::Class::Helper::ResultSet::Shortcut::LimitedPage;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(
  Helper::ResultSet::Shortcut::Rows
  Helper::ResultSet::Shortcut::Page
));

sub limited_page {
  my $self = shift;
  if (@_ == 1) {
    my $arg = shift;
    if (ref $arg) {
      my ( $page, $rows ) = @$arg{qw(page rows)};
      return $self->page($page)->rows($rows);
    } else {
      return $self->page($arg);
    }
  } elsif (@_ == 2) {
    my ( $page, $rows ) = @_;
    return $self->page($page)->rows($rows);
  } else {
    die 'Invalid args passed to get_page method';
  }
}

1;
