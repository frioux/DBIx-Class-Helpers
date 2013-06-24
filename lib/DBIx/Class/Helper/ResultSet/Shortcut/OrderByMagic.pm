package DBIx::Class::Helper::ResultSet::Shortcut::OrderByMagic;

use strict;
use warnings;

# VERSION

use base 'DBIx::Class::Helper::ResultSet::Shortcut::OrderBy';

sub order_by {
    my ($self, @order) = @_;

    ## pass thru if we have a ref (HashRef or ArrayRef)
    if (@order && ref($order[0])) {
        return $self->next::method(@order);
    }

    my @clauses;
    foreach (@order) {
        foreach my $col (split(/\s*,\s*/)) {
            my $dir = 'asc';
            if (substr($col, 0, 1) eq '!') {
                $col = substr($col, 1); # take everything after '!'
                $dir = 'desc';
            }

            ## add csa prefix if necessary
            $col = join('.', $self->current_source_alias, $col)
                if index($col, '.') != -1;

            push @clauses, { "-$dir" => $col };
        }
    }

    return $self->next::method(\@clauses);
}

1;
