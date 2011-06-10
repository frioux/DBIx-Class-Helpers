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

=pod

=head1 SYNOPSIS

Given a L<DBIx::Class::ResultSet> wrap a basic iterator object around it

    my $rs = $schema->resultset('Bar');
    my $itr = DBIx::Class::Helpers::Util::ResultSetItr->new(resultset=>$rs);
    while(my $row = $itr->next) {
      ...
    }

This is really not supported for for public use.  Buyer beware

=head1 DESCRIPTION

A L<DBIx::Class::ResultSet> doesn't give you a lot of information by default
that you might wish to have, such as the location one is at in the set, etc.
This wraps a small class around the resultset to provide these.

Warning: This class was primarily written to support L<DBIx::Class::Helper::ResultSet::Each>
and not for stand alone use.  I will feel free to change this class as needex
to improve the usage of that helper. 

=head1 METHODS

This component defines the following methods.

=head2 index

=head2 count

=head2 escape

=head2 is_first

=head2 is_not_first

=head2 is_even

=head2 is_odd

=head2 resultset

=head2 first

=head2 not_first

=head2 even

=head2 odd

=head2 next

