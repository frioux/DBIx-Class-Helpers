package DBIx::Class::Helper::ResultSet::Shortcut::Search::Like;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::Shortcut::Search::Base');

=head2 like($column || \@columns, $cond)

 $rs->like('lyrics', '%zebra%');
 $rs->like(['lyrics', 'title'], '%zebra%');

=cut

sub like {
    my ($self, $columns, $cond) = @_;

    return $self->_helper_apply_search({ '-like' => $cond }, $columns);
}

1;
