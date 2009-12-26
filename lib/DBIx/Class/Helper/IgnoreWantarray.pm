package DBIx::Class::Helper::IgnoreWantarray;

use parent 'DBIx::Class::Helper::ResultSet::IgnoreWantarray';

# ABSTRACT: (DEPRECATED) Get rid of search context issues

1;

=pod

=head1 DESCRIPTION

This component has been suplanted by
L<DBIx::Class::Helper::ResultSet::IgnoreWantarray>.  In the next major version
(3) we will begin issuing a warning on it's use.  In the major version after
that (4) we will remove it entirely.

