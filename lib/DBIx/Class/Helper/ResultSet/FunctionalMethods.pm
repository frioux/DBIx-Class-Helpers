package DBIx::Class::Helper::ResultSet::FunctionalMethods;

# ABSTRACT: Provide functional methods inspired by JQuery and Underscore.js

use strict;
use warnings;
use DBIx::Class::Helpers::Util::ResultSetItr;

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

sub once {
  my($self, $func, $fail) = @_;
  if(my $row = $self->next) {
    $func->($row);
  } elsif($fail) {
    $fail->();
  }
  return $self;
}

sub if { }
sub around { }
sub collect { }
sub times { }
sub reduce { }
sub bind { }
sub bind_all { }
sub times { }
sub do { }
sub defer {
  ## possible?
}

1;

=pod

=head1 SYNOPSIS

Given a L<DBIx::Class::ResultSet> that consumes this component, such as the
following:

    package MySchema::ResultSet::Bar;

    use Modern::Perl;
    use parent 'DBIx::Class::ResultSet';

    __PACKAGE__->load_components('Helper::ResultSet::FunctionalMethods');

    ## Additional custom resultset methods, if any

    1;

Then later when you have a resulset of that class:

    my $rs = $schema->resultset('Bar');

You can call various functional programming inspired methods.

    TBD

=head1 DESCRIPTION

Perform functional and functional like methods on you L<DBIx::Class::ResultSets>.
Methods here are inspired by JQuery and Underscore.js, however this is not an
attempt to write a full collections API since L<DBIx::Class> and SQL is pretty
functional to begin with.  What you have here is a set of methods we hope make
it easier to perform certain types of common patterns related to extracting
rows of data and making decisions based on that data.  The goal it to help avoid
excessive conditional logic and to allow one to write more compact and neat
code.  For example, you could replace:

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

The second version has less overall lines and character, and it also carefully
encapsulates a very common pattern, which is to loop over all the rows in a
resultset and do something should no rows exist.


=head1 METHODS

This component defines the following methods.

=head2 each

Arguments: $rs->each($coderef, ?$if_empty_coderef)
Returns: Original Resultset OR partly iterated Resultset

Where C<$coderef> is an anonymous subroutine or closure that will get the
instantiated L<DBIx::Class::Helpers::Util::ResultSetItr> object and the
current C<$row> from the set returned.  For example C<$row> in the ResultSet
the $coderef will be executed once.

C<$if_empty_coderef> is an anonymous subroutine or closure that gets
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

You may find this helper leads you to writing more concise and compact code.
Additionally having an iterator object available can be helpful, particularly
when you are in a template and need to display things differently based on if
the row is even/odd, first/last, etc.

You should see the documentation for L<DBIx::Class::Helpers::Util::ResultSetItr>
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

=head2 Around

Arguments: $method||\@methods, $coderef
Returns: Wrapped ResultSet (A Proxy instance)

Allows you to dynamically add a L<Moose> style around method modifier for this
single ResultSet only.

Example:

    $rs->around( search => sub {
      my ($orig, $rs, @args) = @_;
      $rs->$orig(@args);
    });

You may wish to use this to add some sort of 'hook' before passing a resultset
to another method.  Since the anonymous coderef can be a closure, this opens
some possibilties for enabling observer style patterns.

=head2 if

Arguments: ($cond_coderef, $pass_coderef, $fail_coderef)
Returns: Original ResultSet

Perform conditional logic on the ResultSet

Example:

    $rs->if(sub {
      shift->find({id=>100});
    }, sub {
      print 'id 100 has name: '. shift->name;
    }, sub {
      warn 'no id with 100 found';
    });

This is similar to:

    if(my $row = $rs->find({id=>100})) {
      print 'id 100 has name: '. $row->name;
    } else {
      warn 'no id with 100 found';
    }



