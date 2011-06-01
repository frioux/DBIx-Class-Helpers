package DBIx::Class::Helper::Row::StateHook::Accessors;

use strict;
use warnings;

sub set_column {
   my ($self, $column, $value, @rest) = @_;

   my $state = {
      $self->get_inflated_columns,
      $column => $value,
   };

   $state = $self->state_hook($state);

   $value = $state->{$column};

   $self->next::method($column, $value, @rest)
}

1;

