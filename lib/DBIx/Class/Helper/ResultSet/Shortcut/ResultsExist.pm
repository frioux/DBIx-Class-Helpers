package DBIx::Class::Helper::ResultSet::Shortcut::ResultsExist;

use strict;
use warnings;

sub results_exist {
   my $self   = shift;

   $self
      ->result_source
      ->resultset
      ->search({ -exists => $self->as_query })
      ->first
}

1;
