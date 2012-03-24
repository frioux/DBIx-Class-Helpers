package DBIx::Class::Helper::ResultSet::RelatedResultSetDWIM;

use strict;
use warnings;

sub related_resultset {
   my $self = shift;

   $self->throw_exception('') if @_ > 1 && ref $_[0];

   if (ref $_[0]) {
      my @relations = @$_[0];

      my $ret = $self;
      $ret = $ret->related_resultset($_) for @relations;

      return $ret
   } else {
      $self->next::method(@_)
   }
}

1;

