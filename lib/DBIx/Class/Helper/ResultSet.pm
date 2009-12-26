package DBIx::Class::Helper::ResultSet;

use parent qw{
   DBIx::Class::Helper::ResultSet::IgnoreWantarray
   DBIx::Class::Helper::ResultSet::Random
   DBIx::Class::Helper::ResultSet::Union
   DBIx::Class::Helper::ResultSet::VirtualView
};

# ABSTRACT: All the He

1;

=pod

=head1 DESCRIPTION

This is just a simple Helper helper that includes all of the ResultSet Helpers
in one convenient module.

=head2 NOTE

You probably want this applied to your entire schema.  The most convenient
way to do that is to make a base ResultSet and inherit from that in all of
your custom ResultSets as well has make it the default ResultSet for the
non-custom ResultSets.  Example:

 package My::App::Schema::ResultSet;

 use strict;
 use warnings;

 use base 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::ResultSet');

 1;

 package My::App::Schema;

 use base 'DBIx::Class::Schema';

 My::App::Schema->load_namespaces(
    default_resultset_class => 'ResultSet',
 );

 1;

