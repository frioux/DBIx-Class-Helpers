package DBIx::Class::Helper::ResultSet::Shortcut::Search::NotLike;

use strict;
use warnings;

use parent 'DBIx::Class::Helper::ResultSet::Shortcut::Search::Base';

#--------------------------------------------------------------------------#
# not_like
#--------------------------------------------------------------------------#

=head2 not_like($column || \@columns, $cond)

 $rs->not_like('lyrics', '%zebra%');
 $rs->not_like(['lyrics', 'title'], '%zebra%');

=cut

sub not_like {
    my ($self, $columns, $cond) = @_;

    return $self->_helper_apply_search({ '-not_like' => $cond }, $columns);
}

1;
