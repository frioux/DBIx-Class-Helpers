package DBIx::Class::Helper::ResultSet::Shortcut::Search::Null;

use strict;
use warnings;

use parent 'DBIx::Class::Helper::ResultSet::Shortcut::Search::Base';

=head2 null(@columns || \@columns)

 $rs->null('status');
 $rs->null(['status', 'title']);

=cut

sub null {
    my ($self, @columns) = @_;

    return $self->_helper_apply_search({ '=' => undef }, @columns);
}

1;
