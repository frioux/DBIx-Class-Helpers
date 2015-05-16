package DBIx::Class::Helper::ResultSet::Shortcut::Search::NotNull;

use strict;
use warnings;

use parent 'DBIx::Class::Helper::ResultSet::Shortcut::Search::Base';

=head2 not_null(@columns || \@columns)

 $rs->not_null('status');
 $rs->not_null(['status', 'title']);

=cut

sub not_null {
    my ($self, @columns) = @_;

    return $self->_helper_apply_search({ '!=' => undef }, @columns);
}

1;
