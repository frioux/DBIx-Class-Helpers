package DBIx::Class::Helper::ResultSet::Each;

# ABSTRACT: Provide an JQuery-like 'each' method

use strict;
use warnings;
#use DBIx::Class::Helpers::Util::ResultSetItr;

sub each {
  my($self, $func, $fail) = @_;
  $self->throw_exception('Argument must be a CODEREF')
    unless ref($func) eq 'CODE';

  my $itr = DBIx::Class::Helpers::Util::ResultSetItr->new(resultset=>$self);
  while(my $row = $itr->next) {
    $func->($itr, $row);
    if($itr->has_escaped) {
      return $itr->resultset;
    }
  }

  if($fail && $itr->has_not_been_used) {
    $fail->($self);
  }

  return $self;
}

package DBIx::Class::Helpers::Util::ResultSetItr;

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

Given a L<DBIx::Class::ResultSet> that consumes this component, such as the
following:

    package MySchema::ResultSet::Bar;

    use Modern::Perl;
    use parent 'DBIx::Class::ResultSet';

    __PACKAGE__->load_components('Helper::ResultSet::Each');

    ## Additional custom resultset methods, if any

    1;

Then later when you have a resulset of that class:

    my $rs = $schema->resultset('Bar');

    $rs->each(sub {
      my ($each, $row) = @_;

      $each->first(sub {
        print "Hey, this is the first row!";
      });

      if($each->is_odd) {
        print $row->columnname;
      } else {
        $each->escape;
      }
    }, sub {
      my ($rs) = @_;
      warn "The resultset was empty, nothing done...";
    });

=head1 DESCRIPTION

This component gives you a JQuery like C<each> method for a given
L<DBIx::Class::ResultSet>.  Functionally this doesn't do anything you could
not do with a standard perl C<for> or C<while> loop with a bit of control
information, however it might give you more concise and clean code while
reducing repeated basic logic.  For example we create a nice command chain
style to execute different coderefs based on if the resultset has any members
or not, if the index is even or odd, etc.

You may find this saves you some effort when formatting your resultsets in a
template or for some sort of output.

=head1 METHODS

This component defines the following methods.

=head2 each

Arguments: $rs->each($coderef, ?$failure_coderef)

Where C<$coderef> is an anonymous subroutine or closure that will get the
instantiated L<DBIx::Class::Helpers::Util::ResultSetItr> object and the
current C<$row> from the set returned.

C<$failure_coderef> is an anonymous subroutine or closure that gets
executed ONLY if there were no rows in the set.  It gets the C<$resultset>
as an argument (this might change later if we discover a better thing to do
here).

Example: For the given L<DBIx::Class::ResultSet>, iterator over each result.

    $rs->each(sub {
      my ($each, $row) = @_;
      ...
    });

This is functionally similar to something like:

    my $itr = DBIx::Class::Helpers::Util::ResultSetItr->new(resultset=>$rs);
    while(my $row = $itr->next) {
      ...
    }

However the method will return the original $resultset used to initialize it
so that you can continue chaining or building off it.  Of course you will need
to issue a c<reset> for this to be useful.

You may find this helper leads you to writing more concise and compact code.
Additionally having an iterator object available can be helpful, particularly
when you are in a template and need to display things differently based on if
the row is even/odd, first/last, etc.  You should see the documentation for
L<DBIx::Class::Helpers::Util::ResultSetItr> for the methods this object exposes
for use.  You can also glance at the test cases.
