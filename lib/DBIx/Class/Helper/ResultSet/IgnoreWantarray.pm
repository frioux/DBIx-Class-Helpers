package DBIx::Class::Helper::ResultSet::IgnoreWantarray;

# ABSTRACT: Get rid of search context issues

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub search :DBIC_method_is_indirect_sugar{
   $_[0]->throw_exception ('->search is *not* a mutator, calling it in void context makes no sense')
      if !defined wantarray && (caller)[0] !~ /^\QDBIx::Class::/;

   shift->search_rs(@_);
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::ResultSet::IgnoreWantarray});

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
returning an array of your database in array context. See
L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to your
entire schema.

=head1 METHODS

=head2 search

Override of the default search method to force it to return a ResultSet.

