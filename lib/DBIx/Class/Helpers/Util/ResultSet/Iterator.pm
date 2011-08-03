package DBIx::Class::Helpers::Util::ResultSet::Iterator;

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

sub if {
  my ($self, $cond_spec, $pass_cr, $fail_cr, @args) = @_;
  my $cond = ref $cond_spec ? $cond_spec->($self) : $cond_spec;
  if($cond) {
    $pass_cr->($self, @args);
  } elsif($fail_cr) {
    $fail_cr->($self, @args);
  }
  return $self;
}        

## Possible, but requires $rs->count, and don't want that penalty for now or
## deal with any race conditions or conflicts. Maybe we can peek at the cursor
## for some of this info.

sub is_rest {}
sub rest {}
sub is_last {}
sub last {}
sub size {}
sub max {}

1;

=pod

=head1 SYNOPSIS

Given a L<DBIx::Class::ResultSet> wrap a basic iterator object around it

    my $rs = $schema->resultset('Bar');
    my $itr = DBIx::Class::Helpers::Util::ResultSet::Iterator->new(resultset=>$rs);
    while(my $row = $itr->next) {
      ...
    }

=head1 DESCRIPTION

A L<DBIx::Class::ResultSet> doesn't give you a lot of information by default
that you might wish to have, such as the location one is at in the set, etc.
This wraps a small class around the resultset to provide these.

Warning: This class was primarily written to support
L<DBIx::Class::Helper::ResultSet::FunctionalMethods> and not for stand alone use.
I will feel free to change this class as needed to improve the usage of that
helper. 

=head1 METHODS

This component defines the following methods.

=head2 index

A positive number starting from zero which is the location in the set the
current row is at.

=head2 count

A positive number starting from one which is the location in the set the
current row is at.

=head2 escape

Upon completion of the current, stop execution and return the resultset at the
current state.

=head2 is_first

Returns boolean true if the current row is the first in the set

=head2 is_not_first

Returns boolean true if the current row is NOT the first in the set

=head2 is_even

Returns true if the count of the location in the set is even

=head2 is_odd

Returns true if the count of the location in the set is odd

=head2 resultset

Accessor for the raw L<DBIx::Class::ResultSet> we are wrapping.

=head2 first

Args: $coderef, ?$if_empty

If the current row is first in the set, execute a C<$coderef>, otherwise
execute a C<$if_empty> coderef.   Returns the C<$each> object so you can chain.

=head2 not_first

Args: $coderef, ?$if_empty

If the current row is NOT the first in the set, execute a C<$coderef>, otherwise
execute a C<$if_empty> coderef.  Returns the C<$each> object so you can chain.

=head2 even

Args: $coderef, ?$if_empty

If the current row is even in the set, execute a C<$coderef>, otherwise
execute a C<$if_empty> coderef.  Returns the C<$each> object so you can chain.

    $each->even(
      sub { print "Current item is even in index" },
    );

=head2 odd

Args: $coderef, ?$if_empty

If the current row is odd in the set, execute a C<$coderef>, otherwise
execute a C<$if_empty> coderef.  Returns the C<$each> object so you can chain.

    $each->odd(
      sub { print "Current item is odd in index" },
    );

=head2 next

Return the next row in the set or undef.

=head2 if

Arguments: $cond|$cond_codered, $pass_coderef, ?$fail_coderef, ?@args
Returns: $self

Given a condition, execute either a pass or fail anonymous subroutine.  The
fail coderef is optional and the method returns C<$self> for chaining.

    $each->if
    (
      $a>$b,
      sub {  warn "$a > $b" },
      sub {  warn "$a < $b" },
    );

If the condition is a coderef, then C<$self> is passed as an argument along
with any other C<@args> and the return is considered in boolean context.

    $each->if
    (
      sub { shift->is_odd},
      sub {  warn "is odd" },
      sub {  warn "is even" },
    );

