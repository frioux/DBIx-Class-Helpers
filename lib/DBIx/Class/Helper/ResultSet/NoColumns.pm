package DBIx::Class::Helper::ResultSet::NoColumns;

# ABSTRACT: Look ma, no columns!

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub no_columns { $_[0]->search(undef, { columns => [] }) }

1;

=pod

=head1 SYNOPSIS

 package MySchema::ResultSet::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::ResultSet::NoColumns');

 # in code using resultset:
 my $rs = $schema->resultset('Bar')->no_columns->search(undef, {
    '+columns' => { 'foo' => 'me.foo' },
 });

=head1 DESCRIPTION

This component simply gives you a method to clear the set of columns to be
selected.  It's just handy sugar.

See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply this to your
entire schema.

=head1 METHODS

=head2 no_columns

 $rs->no_columns

Returns resultset with zero columns configured, fresh for the addition of new
columns.
