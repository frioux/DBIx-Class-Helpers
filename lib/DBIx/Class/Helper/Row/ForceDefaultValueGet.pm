package DBIx::Class::Helper::Row::ForceDefaultValueGet;

# ABSTRACT: Force get default value
# Text, Varchar etc get '' when undef
# Integer, Float etc get 0 when undef

use strict;
use warnings;

use parent 'DBIx::Class::Row';
use Try::Tiny;

my %force_data_type = (
    integer            => 0,
    int                => 0,
    tinyint            => 0,
    smallint           => 0,
    bigint             => 0,
    double             => 0,
    'double precision' => 0,
    decimal            => 0,
    dec                => 0,
    numeric            => 0,
    real               => 0,
    float              => 0,
    bit                => 0,

    char      => '',
    varchar   => '',
    binary    => '',
    varbinary => '',
    tinyblob  => '',
    blob      => '',
    text      => '',
);

sub get_column {
    my ( $self, $col ) = @_;

    my $value = $self->next::method($col);
    $value = $self->__get_value( $value, $col );
    $value += 0 if try { $self->_is_column_numeric($col) };
    return $value;
}

sub get_columns {
    my ( $self, $col ) = @_;

    my %columns = $self->next::method($col);
    map { $columns{ $_ } = $self->__get_value( $columns{ $_ }, $_ ); $columns{ $_ } += 0 if try { $self->_is_column_numeric($_) } } keys %columns;

    return %columns;
}

sub __get_value {
    my ( $self, $value, $col ) = @_;
    my $info  = $self->column_info($col);
    my $data_type = $info->{ data_type };

    if ( not defined $value && $data_type ) {
        $value = $force_data_type{ $data_type } if exists $force_data_type{ $data_type };
    }
    return $value;
}

1;
