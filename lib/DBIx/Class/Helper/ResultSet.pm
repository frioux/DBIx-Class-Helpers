package DBIx::Class::Helper::ResultSet;

# ABSTRACT: All the ResultSet Helpers in one place

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw{
   Helper::ResultSet::AutoRemoveColumns
   Helper::ResultSet::CorrelateRelationship
   Helper::ResultSet::IgnoreWantarray
   Helper::ResultSet::Me
   Helper::ResultSet::NoColumns
   Helper::ResultSet::Random
   Helper::ResultSet::RemoveColumns
   Helper::ResultSet::ResultClassDWIM
   Helper::ResultSet::SearchOr
   Helper::ResultSet::SetOperations
   Helper::ResultSet::Shortcut
};

1;

=pod

=head1 DESCRIPTION

This is just a simple Helper helper that includes all of the ResultSet Helpers
in one convenient module.  It does not include deprecated helpers.

=head2 NOTE

You probably want this applied to your entire schema.  The most convenient
way to do that is to make a base ResultSet and inherit from that in all of
your custom ResultSets as well has make it the default ResultSet for the
non-custom ResultSets.  Example:

 package My::App::Schema::ResultSet;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::ResultSet');

 1;

 package My::App::Schema;

 use parent 'DBIx::Class::Schema';

 My::App::Schema->load_namespaces(
    default_resultset_class => 'ResultSet',
 );

 1;

