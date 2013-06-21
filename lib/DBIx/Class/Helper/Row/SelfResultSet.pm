package DBIx::Class::Helper::Row::SelfResultSet;

use strict;
use warnings;

# ABSTRACT: Easily use ResultSet methods for the current row

# VERSION

sub self_rs {
   my ($self) = @_;

   my $src = $self->result_source;
   my $rs = $src->resultset;
   my $me = $rs->current_source_alias;
   return $rs->search({
          # perl, sometimes I hate your guts
      map +( "$me.$_" => $self->get_column($_) ), $src->primary_columns
   })
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

=head1 METHODS

=head2 self_rs

 $row->self_rs

returns a ResultSet containing B<just> the current row.
