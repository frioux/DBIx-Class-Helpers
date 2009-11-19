package DBIx::Class::Helper::Random;

use strict;
use warnings;

use Scalar::Defer;

# ABSTRACT: Get random rows from a ResultSet

sub rand {
   my $self   = shift;
   my $amount = shift || 1;

   if ($amount == 1) {
      return $self->slice (int rand defer { $self->count } );
   } else {

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

 my $row  = $schema->resultset('Bar')->rand->single;

 my @rows = $schema->resultset('Bar')->rand(4)->all;

=head1 DESCRIPTION


=head1 METHODS

=head2 rand

