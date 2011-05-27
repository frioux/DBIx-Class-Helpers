package DBIx::Class::Helper::Row::StateHook;

use strict;
use warnings;

sub set_column {
   my ($self, $column, $value, @rest) = @_;

   my $state = {
      $self->get_inflated_columns,
      $column => $value,
   };

   $self->state_hook($state);

   $value = $state->{$column};

   $self->next::method($column, $value, @rest);
}

sub update {
   my ($self, $state, @rest) = @_;

   $state = {
      $self->get_inflated_columns,
      %{ $state || {} },
   };

   $self->state_hook($state);

   $self->next::method($state, @rest);
}

sub insert {
   my ($self, $state, @rest) = @_;

   $self->state_hook($state || {});

   $self->next::method($arg, @rest);
}

sub state_hook {
   my ($self, $state) = @_;

}

1;

