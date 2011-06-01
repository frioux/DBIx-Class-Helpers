package DBIx::Class::Helper::Row::StateHook::New;

use strict;
use warnings;

sub new {
   my ($class, $state, @rest) = @_;

   my $self = $class->next::method($state, @rest);

   $self->state_hook($state);

   return $self
}

1;
