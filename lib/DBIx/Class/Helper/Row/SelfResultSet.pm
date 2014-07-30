package DBIx::Class::Helper::Row::SelfResultSet;

use strict;
use warnings;

# ABSTRACT: Easily use ResultSet methods for the current row

sub self_rs {
   my ($self) = @_;

   my $rs = $self->result_source->resultset;
   return $rs->search($self->ident_condition)
}

1;

=pod

=head1 SYNOPSIS

In result class:

 __PACKAGE__->load_components('Helper::Row::SelfResultSet');

Elsewhere:

 $row->self_rs->$some_rs_method->single

=head1 DESCRIPTION

Sometimes you need to be able to access a ResultSet containing just the current
row.  A good reason to do that would be if you had a ResultSet method that adds
in some calculated data, like counts of a relationship.  You could use this to
get at that counted data without duplicating the logic for the counting.

Due to primitives provided by L<DBIx::Class::PK> this references the current
values, or in C<DBIx::Class> terms, the dirty values.  So if you modify the
primary columns it will be temporarily incorrect.  For what it's worth I'm not
married to this behavior and I'd rather you get in touch with me before you
depend on it.

=head1 METHODS

=head2 self_rs

 $row->self_rs

returns a ResultSet containing B<just> the current row.
