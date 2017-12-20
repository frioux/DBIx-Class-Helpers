package DBIx::Class::Helper::Row::Types;

# ABSTRACT: Use Types to define rows

use strict;
use warnings;

use Hash::Merge qw/ merge /;
use Scalar::Util qw/ blessed /;
use Types::SQL::Util qw/ column_info_from_type /;

sub add_columns {
    my ( $self, @args ) = @_;

    my @cols = map { $self->_apply_types_to_column_defition($_) } @args;

    $self->next::method(@cols);
}

sub _apply_types_to_column_defition {
    my ( $self, $column_info ) = @_;

    return $column_info unless ref $column_info;

    my $type = $column_info->{isa} or return $column_info;

    my %info = column_info_from_type($type);

    return merge( $column_info, \%info );
}

1;

=pod

=head1 SYNOPSIS

In result class:

  use Types::SQL -types;
  use Types::Standard -types;

 __PACKAGE__->load_components('Helper::Row::Types');

 __PACKAGE__->add_column(
    name => {
      isa => Maybe[ Varchar[64] ],
    },
 );

=head1 DESCRIPTION

This helper allows you to specify column information by passing a
L<Type::Tiny> object.

Note that this I<does not> enforce that the data is of that type. It
just allows you to use types as a shorthand for specifying the column
info.

A future version may add options to enforce types or coerce data.

=head1 SEE ALSO

L<Types::SQL::Util>

L<Types::Standard>

=cut
