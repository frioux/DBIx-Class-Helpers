package DBIx::Class::Helper::ResultSet::OneRow;

# ABSTRACT: The first you always wanted

use strict;
use warnings;

sub one_row { shift->search(undef, { rows => 1})->next }

1;

=pod

=head1 SYNOPSIS

 # note that this is normally a component for a ResultSet
 package MySchema::ResultSet::Person;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::ResultSet::OneRow');

 sub person_named {
    $_[0]->search({ name => $_[1] })->one_row
 }

=head1 DESCRIPTION

This component codifies an alternate version of L<DBIx::Class::ResultSet/first>.
In practical use, C<first> allows a user to do something like the following:

 my $rs = $schema->resultset('Foo')->search({ name => 'bar' });
 my $first = $rs->first;
 my @rest;
 while (my $row = $rs->next) {
    push @rest, $row
 }

Problematically, if you call C<first> without the while loop afterwards B<and>
you got back more than one row, you are leaving a cursor open.  Depending on
your database this could increase memory usage or cause errors with later
queries.

Fundamentally the difference is that when you use C<one_row> you are guaranteed
to exhaust the underlying cursor.

Generally speaking, unless you are doing something unusual, C<one_row> is a good
default.

=head1 METHODS

=head2 one_row

Limits the ResultSet to a single row, and then returns the matching result
object. In case no rows match, C<undef> is returned as normal.

=head1 THANKS

Thanks to Aran Clary Deltac (BLUEFEET) for initially writing this module, and
thanks to L<ZipRecruiter|https://www.ziprecruiter.com> for sponsoring that
initial developmentl
