package DBIx::Class::Helper::ResultSet::Shortcut::ResultsExist;

use strict;
use warnings;

# ABSTRACT: Determine if a query would return results

sub results_exist {
    my $self   = shift;
    my $search = shift;

    my $rs = $self->search( $search );
    (   $rs->result_source->resultset->search( {},
            { select => { exists => $rs->as_query } } )->cursor->next
    )[0] ? 1 : 0;
}

1;

=pod

=head1 SYNOPSIS

    my $results_exist  = $schema->resultset('Bar')->search({...})->results_exist;

=head1 DESCRIPTION

This component is a shortcut for the case where you'd like to know whether a
query might return data, but you don't actually want the overhead of selecting
and returning columns.  Think of the "SELECT 1 FROM Foo IF ..." type of query.

=head1 METHODS

=head2 results_exist

This method takes no arguments and will return 1 if results exists, 0 if they
do not.

=cut
