package DBIx::Class::Helper::ResultSet::ModifyMethods;

# ABSTRACT: Methods to control flow and run commands

use strict;
use warnings;

my $anon_class_count = 0; ## TODO this is going to get ugly after a while
## should see what the Moose people do.

sub around {
  my($self, $method_spec, $coderef) = @_;
  my $package = ref($self) . '::ANON_DBIC_HELPER_AROUND_'. $anon_class_count++;
  my @methods = ref($method_spec) ? @$method_spec : ($method_spec);
  for my $method(@methods) {
    no strict 'refs';
    my $orig = $self->can($method);
    @{$package . '::ISA'} = (ref($self));
    *{$package . '::' . $method} = sub {
        my ($self, @args) = @_;
        $coderef->($orig, $self, @args);
    };
    bless $self, $package;
  }
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

There may be times when you wish to hook into a resultset

=head1 METHODS

This component defines the following methods.

=head2 around

Arguments: $method||\@methods, $coderef
Returns: Wrapped ResultSet (A Proxy instance)

Allows you to dynamically add a L<Moose> style around method modifier for this
single ResultSet only.

Example:

    $rs->around( search => sub {
      my ($orig, $rs, @args) = @_;
      return $rs->$orig(@args);
    });

You may wish to use this to add some sort of 'hook' before passing a resultset
to another method.  Since the anonymous coderef can be a closure, this opens
some possibilties for enabling observer style patterns.  You can also use this
to modify C<@args>, etc, just as in L<Moose>, or even change the return value.


