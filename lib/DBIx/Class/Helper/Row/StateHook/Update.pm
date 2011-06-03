package DBIx::Class::Helper::Row::StateHook::Update;

use strict;
use warnings;

sub update {
   my ($self, $state, @rest) = @_;

   $state = {
      $self->get_inflated_columns,
      %{ $state || {} },
   };

   $state = $self->state_hook(update => $state);

   $self->next::method($state, @rest)
}

1;

