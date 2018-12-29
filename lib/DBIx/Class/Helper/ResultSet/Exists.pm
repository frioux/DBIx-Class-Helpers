package DBIx::Class::Helper::ResultSet::Exists;

# ABSTRACT: Allow EXISTS/NOT EXISTS subqueries with DBIx::Class

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub _handle_exists {
    my ( $self, $exists, $exists_subq, $join ) = @_;

    die "Calling ->exists without a join query doesn't make any sense" unless $join && %$join;

    die "You need to specify an alias on your exists subquery to allow joining with the main query" unless $exists_subq->{attrs}{alias} ne $self->{attrs}{alias};

    my %constraints;

    # We could have used something like
    # ResultSource->_resolve_relationship_condition but this would not be so
    # flexible as we may want to be doing the exists against joined tables'
    # relationships in the main query
    while ( my ( $self, $foreign ) = each %$join ) {
        $constraints{$self} = { -ident => $foreign };
    }

    # Don't fetch all the columns - just fetch a 1...
    $exists_subq = $exists_subq->search_rs(
        \%constraints,
        {
            select => \'1',
        }
    );

    my ( $sql, @bind ) = @${ $exists_subq->as_query };
    return $self->search_rs( \[ "$exists $sql", @bind ] );
}

sub exists { shift->_handle_exists( 'EXISTS', @_ ) }
sub not_exists { shift->_handle_exists( 'NOT EXISTS', @_ ) }

1;

=pod

=head1 DESCRIPTION

Generate (NOT) EXISTS clauses in DBIx::Class syntax.

JOIN allows you to select a set of rows in one table based on parameters in a
second table, however if it is a one-to-many join then you will get duplicates
of some rows if you query like that.

In situations like these, you can use something like:

    column => { -in => $other_table->get_column( ... )->as_query }

however method does not work if you are trying to do it on a composite key
field.

The correct SQL way is to use EXISTS ( subquery ) where subquery returns a true
or false value and can reference out to the surrounding tables, however
DBIx::Class doesn't have any natural support for this. Thats where this module
comes in.

=head1 METHODS

=head2 exists

    $rs = $rs->exists(
                $dbic->resultset('User')->search( user_criteria, { alias => 'exists_query' } ),
                { username => 'me.username' }
            );

Generates something like:

  WHERE
  ...
    AND EXISTS (
        SELECT 1
        FROM user AS exists_query
        WHERE
            user_criteria
            AND exists_query.username = me.username
    )

You must pass an alias option to the exists subquery so that the join condition
can reference the main query, otherwise they will both be called 'me' by
default. You also need to specify a join condition otherwise it makes no sense
to do an EXISTS query.

=head2 not_exists

Like C<exists> but generates NOT EXISTS ( subquery ).

=cut

