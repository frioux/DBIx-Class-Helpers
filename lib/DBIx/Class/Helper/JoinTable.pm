package DBIx::Class::Helper::JoinTable;

use parent 'DBIx::Class::Helper::Row::JoinTable';

use Carp::Clan;
carp 'This module is deprecated!  Please use the namespaced version instead!' if $VERSION >= 3;
croak 'This module is deprecated!  Please use the namespaced version instead!' if $VERSION >= 4;

# ABSTRACT: (DEPRECATED) Easily set up join tables with DBIx::Class

1;

=pod

=head1 DESCRIPTION

This component has been suplanted by
L<DBIx::Class::Helper::Row::JoinTable>.  In the next major version
(3) we will begin issuing a warning on it's use.  In the major version after
that (4) we will remove it entirely.

