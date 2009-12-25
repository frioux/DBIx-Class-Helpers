package DBIx::Class::Helper::ResultSet::Union;

use strict;
use warnings;

# ABSTRACT: Do unions in DBIx::Class

sub union {
   my ( $self, $other) = @_;

   $other = [$other] if ref $other ne 'ARRAY';

   push @{$other}, $self;
   my @sql;
   my @params;

   for (@{$other}) {
      $self->throw_exception('ResultSource of queries passed to union do not match!')
         unless ref $self->_result_class eq ref $_->_result_class;

      my $attrs = $_->_resolved_attrs;

      my ($sql, $bind) = $self->result_source->storage->_select_args_to_query(
         $attrs->{from}, $attrs->{select}, $attrs->{where}, $attrs
      );

      push @sql, $sql;
      push @params, @{$bind};
   }

   my $query = q<(> . join(' UNION ', @sql). q<)>;

   return $self->result_source->resultset->search(undef, {
      from => [{
         me             => \[ $query, @params ],
         -alias         => $self->current_source_alias,
         -source_handle => $self->result_source->handle,
      }]
   });
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::IgnoreWantarray});

 ...

 1;

And then else where, like in a controller:

 my $rs = $self->paginate(
   $schema->resultset('Foo')->search({
      name => 'frew'
   })
 );

=head1 DESCRIPTION

This component makes search always return a ResultSet, instead of
returning an array of your database in array context.

=head1 METHODS

=head2 search

Override of the default search method to force it to return a ResultSet.

=head2 NOTE

You probably want this applied to your entire schema.  The most convenient
way to do that is to make a base ResultSet and inherit from that in all of
your custom ResultSets as well has make it the default ResultSet for the
non-custom ResultSets.  Example:

 package My::App::Schema::ResultSet;

 use strict;
 use warnings;

 use base 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::IgnoreWantarray');

 1;

 package My::App::Schema;

 use base 'DBIx::Class::Schema';

 My::App::Schema->load_namespaces(
    default_resultset_class => 'ResultSet',
 );

 1;

