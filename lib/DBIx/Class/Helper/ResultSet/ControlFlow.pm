package DBIx::Class::Helper::ResultSet::ControlFlow;

# ABSTRACT: Methods to control flow and run commands

use strict;
use warnings;
use DBIx::Class::Helpers::Util::ResultSet::Iterator;

sub each {
  my($self, $func_proto, $fail) = @_;

  ## validate and normalize the function prototype
  unless(
    $func_proto and (
    ref($func_proto) eq 'CODE' or
    ref($func_proto) eq 'ARRAY' )
  ) {
    $self->throw_exception('Argument must be a CODEREF or ARRAYREF')
  }

  ## create a local iterator for the each function
  my @funcs;
  my $func_itr = sub {
    @funcs = ref($func_proto) eq 'ARRAY' ? @$func_proto : $func_proto unless @funcs;
    return shift @funcs;
  };

  ## Iterate over the resultset
  my $itr = DBIx::Class::Helpers::Util::ResultSet::Iterator->new(resultset=>$self);
  while(my $row = $itr->next) {
    $func_itr->()->($itr, $row);
    if($itr->has_escaped) {
      return $itr->resultset;
    }
  }

  ## Handle fails
  if($fail && $itr->has_not_been_used) {
    $fail->($self);
  }

  ## ALlow chaining methods
  return $self;
}

sub once {
  my($self, $func, $fail) = @_;
  if(my $row = $self->next) {
    $func->($row);
  } elsif($fail) {
    $fail->();
  }
  return $self;
}

sub do {
  my($self, $func, @args) = @_;
  $func->($self->search, @args);
  return $self;
}

sub times {
  my($self, $times, $func, @args) = @_;
  $self->do($func, @args) for 1.. $times;
  return $self;
}

1;

=pod

=head1 SYNOPSIS

Given a L<DBIx::Class::ResultSet> that consumes this component, such as the
following:

    package MySchema::ResultSet::Bar;

    use Modern::Perl;
    use parent 'DBIx::Class::ResultSet';

    __PACKAGE__->load_components('Helper::ResultSet::ControlFlow');

    ## Additional custom resultset methods, if any

    1;

Then later when you have a resulset of that class:

    my $rs = $schema->resultset('Bar');

You can call methods directly on your object which are related to control flow
and looping over the items in you resultset.

    $rs->do(sub {
      print shift->find({id=>1} ? 'found one' : 'nope';
    })->each(sub {
      my ($each, $row) = @_;
      print $each->is_odd ? $row->name . ' is odd' : 'nope, not odd';
    });

=head1 DESCRIPTION

There are times where Perl's procedural syntax for control flow and looping
leads to excessively verbose code.  For those times we present this helper
which is designed to encapsulate some very common control flow and loop patterns
for L<DBIx::Class> users.

The methods are OO in nature and designed to be compact and concise.

Additionally, we have tried to write these methods to allow for a 'chaining'
approach that you can't replicate with traditional Perl control and looping
structures.  Each control flow method returns the original resultset so you
can proceed as though it is unaltered (unless of course you alter it somehow
like with an insert or update).

The goal it to help avoid excessive conditional logic and to allow one to write
more compact and neat code.  For example, you could replace:

    my $has_rows;
    while(my $row = $rs->next) {
      $has_rows = 1;
      ## Do something
    }
    unless($has_rows) {
      warn 'no rows!';
    }

With something like

    $rs->each(sub {
      my ($each, $row) = @_;
      ## Do Something
    }, sub {
      warn 'no rows!';
    });

The second version has less overall lines and characters, and it also carefully
encapsulates a very common pattern, which is to loop over all the rows in a
resultset and do something should no rows exist.  Also, the L</each> method
returns the original C<$rs> so you could chain commands:

    $rs->each(sub {
      my ($each, $row) = @_;
      ## Do Something
    }, sub {
      warn 'no rows!';
    })->do(sub {
      my $rs = shift;
      ## Do something else
    });

There may be cases in your logical flow where this type of programming is more
clear and simple; in other cases traditional Perl control and looping might be
better.  These methods give you an option.  On the other hand you might think
this is all pointless line noise.  As you wish :)

=head1 METHODS

This component defines the following methods.

=head2 each

Arguments: $rs->each($coderef|\@$coderef, ?$if_empty_coderef)
Returns: Original Resultset OR partly iterated Resultset

Where C<$coderef> is an anonymous subroutine or closure that will get the
instantiated L<DBIx::Class::Helpers::Util::ResultSet::Iterator> object and the
current C<$row> from the set returned.  For example C<$row> in the ResultSet
the $coderef will be executed once.

C<$if_empty_coderef> is an anonymous subroutine or closure that gets
executed ONLY if there were no rows in the set.  It gets the C<$resultset>
as an argument (this might change later if we discover a better thing to do
here).

In the case where the first argument is an arrayref of coderefs, we automatically
iterate over each coderef for each result in the set in turn and reset the
coderef iterator as needed to make sure we hit every item in the set.  Please
be aware that in the case where the arrayref of coderefs is longer than the
available results in the set, this means that not all coderefs will be invoked
and this happens without an exception being thrown.

Example: For the given L<DBIx::Class::ResultSet>, iterator over each result.

    $rs->each(sub {
      my ($each, $row) = @_;
      ...
    });

This is functionally similar to something like:

    my $itr = DBIx::Class::Helpers::Util::ResultSet::Iterator->new(resultset=>$rs);
    while(my $row = $itr->next) {
      ...
    }

However the method will return the original $resultset used to initialize it
so that you can continue chaining or building off it.  Of course you will need
to issue a c<ResultSet->reset> for this to be useful.

Here's a more detailed example.

    $rs->each(sub {
      my ($each, $row) = @_;

      $each->first(sub {
        print "Hey, this is the first row!";
      });

      if($each->is_odd) {
        print $row->columnname;
      } else {
        return $each->escape;
      }
    }, sub {
      my ($rs) = @_;
      warn "The resultset was empty, nothing done...";
    });

Finally one example using an arrayref as the first argument:

    $rs->each(
      [
        sub { ... },
        sub { ... },
        sub { ... },
      ], sub {
        my ($rs) = @_;
        warn "The resultset was empty, nothing done...";
      }
    );

You may find this helper leads you to writing more concise and compact code.
Additionally having an iterator object available can be helpful, particularly
when you are in a template and need to display things differently based on if
the row is even/odd, first/last, etc.

You should see the documentation for L<DBIx::Class::Helpers::Util::ResultSet::Iterator>
for the methods this object exposes for use.

=head2 once

Arguments: $rs->once($coderef, ?$if_empty_coderef)
Returns: Partly iterated Resultset

Works just like L</each> expect instead of iterating over the entire resultset
we just take the first C<$row>.

Example

    $rs->once( sub {
      my ($row) = @_;
    }, sub {
      warn 'no rows left!';
    })->each( ... );

Useful to isolate the logic for the first row in a resultset.

=head2 do

Arguments: $coderef, ?@args
Returns: Original Resultset

Do a coderef with the resultset passed as an argument.

    $rs->do(sub {
      my ($rs, $arg) = @_;
      $rs->find({id=>$arg});
    }, 100);

If you pass more than one argument, all the extra arguments will be send to the
anonymous coderef.

=head2 times

Arguments: $integer, $coderef, ?@args
Returns: Original Resultset

Basically this calls L</do> a number of times equal to the first argument.

    $rs->times(3, sub {
      my $rs = shift;
      ...
    });

