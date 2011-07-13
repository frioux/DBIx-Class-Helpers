package DBIx::Class::Helper::ResultSet::ModifyMethods;

# ABSTRACT: Methods to control flow and run commands

use strict;
use warnings;

sub around { shift->_wrap_methods('around', @_) }
sub before { shift->_wrap_methods('before', @_) }
sub after { shift->_wrap_methods('after', @_) }

my $anon_class_count = 0;
sub _wrap_methods {
  my($self, $type, $method_spec, $modifier) = @_;
  my @methods = ref($method_spec) ? @$method_spec : ($method_spec);
  my $package = ref($self) . '::ANON_DBIC_HELPER_'. uc($type). '_'. join('_', @methods). '_'. $anon_class_count++;
  for my $method(@methods) {
    no strict 'refs';
    my $orig = $self->can($method);
    die "There is no method '$method' on ". ref($self)
      unless $orig;
    @{$package . '::ISA'} = (ref($self));
    *{$package . '::' . $method} = "_generate_$type"->($self, $orig, $modifier);
    bless $self, $package;
  }
  return $self;

}

sub _generate_around {
  my ($self, $orig, $modifier) = @_;
  return sub {
    my ($rs, @args) = @_;
    $modifier->($orig, $rs, @args);
  };
}

sub _generate_before {
  my ($self, $orig, $modifier) = @_;
  return sub {
    my ($rs, @args) = @_;
    $rs->$modifier(@args);
    $rs->$orig(@args);
  };
}

sub _generate_after {
  my ($self, $orig, $modifier) = @_;
  return sub {
    my ($rs, @args) = @_;
    my $result = $rs->$orig(@args);
    $rs->$modifier(@args);
    return $result;
  };
}

1;

=pod

=head1 SYNOPSIS

Given a L<DBIx::Class::ResultSet> that consumes this component, such as the
following:

    package MySchema::ResultSet::Bar;

    use Modern::Perl;
    use parent 'DBIx::Class::ResultSet';

    __PACKAGE__->load_components('Helper::ResultSet::ModifyMethods');

    ## Additional custom resultset methods, if any

    1;

Then later when you have a resulset of that class:

    my $rs = $schema->resultset('Bar');

You can modify instance methods similarly to L<Moose> method modifiers.

    $rs->around( search => sub {
      my ($orig, $rs, @args) = @_;
      print "Search was called!";
      return $rs->$orig(@args);
    });

The above would wrap the search method such that when someone called it on C<$rs>
you'd see "Search was called!"" in STDOUT

=head1 DESCRIPTION

There may be times when you wish to hook a resultset before passing a resultset
to another method.  Since the anonymous coderef can be a closure, this opens
some possibilties for enabling observer style patterns.  You can also use this
to modify C<@args>, etc, just as in L<Moose>, or even change the return value.

=head1 METHODS

This component defines the following methods.

=head2 around

Arguments: $method||\@methods, $coderef
Returns: Wrapped ResultSet (A Proxy instance)

Allows you to dynamically add a L<Moose> style around method modifier for this
single ResultSet only which wraps a method or arrayref of methods and grants
you full control over how the wrapped method is called.  You can even use this
to inspect and modify arguments.

Example:

    $rs->around( search => sub {
      my ($orig, $rs, @args) = @_;
      return $rs->$orig(@args);
    });

=head2 before

Arguments: $method||\@methods, $coderef
Returns: Wrapped ResultSet (A Proxy instance)

Allows you to run some code before a method or arrayref of methods on your
ResultSet instance before it actually runs.  You can't use this to modify
incoming C<args> to a method or control the method.  Use this to safely
hook a method when you want to do something and not potentially effect the
actually running of the wrapped method.

    $rs->before( search => sub {
      my ($rs, @args) = @_;
      return $rs->$orig(@args);
    });

=head2 after

Arguments: $method||\@methods, $coderef
Returns: Wrapped ResultSet (A Proxy instance)

Allows you to run some code before a method or arrayref of methods on your
ResultSet instance after it actually runs.  You can't use this to modify
incoming C<args> to a method or control the method.  Use this to safely
hook a method when you want to do something and not potentially effect the
actually running of the wrapped method.

    $rs->after( search => sub {
      my ($rs, @args) = @_;
      return $rs->$orig(@args);
    });

