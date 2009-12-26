package DBIx::Class::Helper::ResultSet::Random;

use strict;
use warnings;

# ABSTRACT: Get random rows from a ResultSet

sub rand {
   my $self   = shift;
   my $amount = shift || 1;

   if ($amount == 1) {
      return $self->slice( int rand $self->count );
   } else {
      $self->throw_exception('rand is not yet implemented for multiple random values');
   }
}

1;

=pod

=head1 SYNOPSIS

 # note that this is normally a component for a ResultSet
 package MySchema::ResultSet::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::Random');

 # in code using resultset:
 my $random_row  = $schema->resultset('Bar')->rand->single;

=head1 DESCRIPTION

This component allows convenient selection of random rows.

=head1 METHODS

=head2 rand

Currently this method will return a ResultSet containing a single random row
from the given ResultSet.  In the future it will take an argument of how many
random rows should be included in the ResultSet.
