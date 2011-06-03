package DBIx::Class::Helper::Row::StateHook::Insert;

use strict;
use warnings;

sub insert {
   my ($self, $state, @rest) = @_;

   $state = $self->state_hook(insert => $state || {});

   $self->next::method($state, @rest)
}

1;

