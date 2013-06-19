package DBIx::Class::Helper::ResultSet::Shortcut::OrderBy;

use strict;
use warnings;

# VERSION

sub order_by {
    my ($self, @order) = @_;

    ## pass thru if we have a HashRef format
    if (@order && ref($order[0]) eq 'HASH') {
        return $self->search(undef, { order_by => $order[0] });
    }

    my @clauses;
    foreach (@order) {
        foreach my $col (split(/\s*,\s*/)) {
            my $dir = 'asc';
            if (substr($col, 0, 1) eq '!') {
                $col = substr($col, 1); # take everything after '!'
                $dir = 'desc';
            }
            push @clauses, { "-$dir" => join('.', $self->current_source_alias, $col) };
        }
    }

    return $self->search(undef, { order_by => \@clauses });
}

1;
