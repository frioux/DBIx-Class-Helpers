package DBIx::Class::Helper::Row::StateHook::PostInsert;

use strict;
use warnings;

sub insert {
   my ($self, @rest) = @_;

   my $ret = $self->next::method(@rest);

   $self->state_hook('post-insert' => { $self->get_inflated_columns });

   return $ret
}

1;

