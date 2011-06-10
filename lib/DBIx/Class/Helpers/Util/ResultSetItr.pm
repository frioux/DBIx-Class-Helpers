package DBIx::Class::Helpers::Util::ResultSetItr;

# ABSTRACT: Put an Iterator around a Resultset

use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  bless(\%args, $class);
}

sub index { shift->{index} }
sub _inc_index { shift->{index}++ }
sub _init_index { shift->{index} ||= 0 }
sub _has_index { defined shift->{index} }
sub _init_or_inc_index {
  my $self = shift;
  $self->_has_index  ?
    $self->_inc_index : $self->_init_index;
}

sub count { shift->index + 1 }

sub escape { shift->{escape} = 1 }
sub has_escaped { shift->{escape} ? 1:0 }
sub has_not_been_used { defined shift->{index} ? 0:1 }

sub is_first { shift->index == 0 ? 1:0 }
sub is_not_first { shift->index == 0 ? 0:1 }

sub is_even { shift->index % 2 ? 1:0 }
sub is_odd { shift->index % 2 ? 0:1 }
sub resultset { shift->{resultset} }

sub first {
  my ($self, $code, $fail) = @_;
  if($self->is_first) {
      $code->($self);
  } elsif($fail) {
      $fail->($self);
  }
  return $self;
}

sub not_first {
  my ($self, $code, $fail) = @_;
  if($self->is_not_first) {
      $code->($self);
  } elsif($fail) {
      $fail->($self);
  }
  return $self;
}

sub even {
  my ($self, $code, $fail) = @_;
  if($self->is_even) {
      $code->($self);
  } elsif($fail) {
      $fail->($self);
  }
  return $self;
}

sub odd {
  my ($self, $code, $fail) = @_;
  if($self->is_odd) {
      $code->($self);
  } elsif($fail) {
      $fail->($self);
  }
  return $self;
}

sub next {
  my $self = shift;
  if(my $next = $self->resultset->next) {
    $self->_init_or_inc_index;
    return $next;
  } else {
    return;
  }
}

## Possible, but requires $rs->count, and don't want that penalty for now

sub last {}
sub size {}
sub max {}

1;
