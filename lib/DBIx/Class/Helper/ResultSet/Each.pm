package DBIx::Class::Helper::ResultSet::Each;

# ABSTRACT: Provide an JQuery-like 'each' method 

use strict;
use warnings;
use DBIx::Class::Helpers::Util::ResultSetItr;

sub each {
  my($self, $func) = @_;
  $self->throw_exception('Argument must be a CODEREF')
    unless ref $func eq 'CODE';

  my $itr = DBIx::Class::Helpers::Util::ResultSetItr->new(resultset=>$rs);
  while(my $row = $itr->next) {
    $func->($itr, $row);
    last if $itr->has_escaped;
  }
  return $self;
}

package DBIx::Class::Helpers::Util::ResultSetItr;

use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  bless(%args, $class);
}

sub index { shift->{index} }
sub _inc_index { shift->{index}++ }
sub _init_index { shift->{index} ||= 0 }
sub _has_index { defined shift->{index} }

sub _init_or_inc_index {
  my $self = shift;
  $self->_has_index  ?
    $self->_init_index : $self->_inc_index;
}

sub count { shift->index + 1 }
sub first { shift->index == 0 ? 1:0 }
sub escape { shift->{escape} = 1 }
sub has_escaped { shift->{escape} ? 1:0 }

sub odd { shift->index % 2 ? 1:0 }
sub even { shift->index % 2 ? 0:1 }

sub _resultset { shift->{resultset} }

sub next {
  my $self = shift;
  if(my $next = $self->_resultset->next) {
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
      my ($itr, $row) = @_;
      ...
    });

=head1 DESCRIPTION

This component gives you a JQuery like C<each> method for a given
L<DBIx::Class::ResultSet>.

=head1 METHODS

This component defines the following methods.

=head2 each

For the given L<DBIx::Class::ResultSet>, iterator over each result:

    $rs->each(sub {
      my ($idx, $row) = @_;
      ...
    });

This is functionally similar to something like:

    my $idx = DBIx::Class::Helpers::Util::ResultSetItr->new(resultset=>$rs);
    while(my $row = $idx->next) {
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
for use.
