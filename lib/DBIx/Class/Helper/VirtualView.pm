package DBIx::Class::Helper::VirtualView;

use parent 'DBIx::Class::Helper::ResultSet::VirtualView';
use Carp::Clan;
carp 'This module is deprecated!  Please use the namespaced version instead!' if $DBIx::Class::Helper::VirtualView::VERSION >= 3;
croak 'This module is deprecated!  Please use the namespaced version instead!' if $DBIx::Class::Helper::VirtualView::VERSION >= 4;

# ABSTRACT: (DEPRECATED) Clean up your SQL namespace

1;

=pod

=head1 DESCRIPTION

This component has been suplanted by
L<DBIx::Class::Helper::ResultSet::VirtualView>.  In the next major version
(3) we will begin issuing a warning on it's use.  In the major version after
that (4) we will remove it entirely.

