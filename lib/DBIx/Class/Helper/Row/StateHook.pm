package DBIx::Class::Helper::Row::StateHook;

use strict;
use warnings;

sub update {
   my ($self, $state, @rest) = @_;

   $state = {
      $self->get_inflated_columns,
      %{ $state || {} },
   };

   $state = $self->state_hook($state);

   $self->next::method($state, @rest)
}

sub insert {
   my ($self, $state, @rest) = @_;

   $state = $self->state_hook($state || {});

   $self->next::method($state, @rest)
}

sub state_hook {
   my ($self, $state) = @_;

   return $state
}

1;

