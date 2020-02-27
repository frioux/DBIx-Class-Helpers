package DBIx::Class::Helper::ResultSet::AutoRemoveColumns;

# ABSTRACT: Automatically remove columns from a ResultSet

use strict;
use warnings;

use parent 'DBIx::Class::Helper::ResultSet::RemoveColumns','DBIx::Class::AccessorGroup';

__PACKAGE__->mk_group_accessors(inherited => '_fetchable_columns');

my %dont_fetch = (
   text  => 1,
   ntext => 1,
   blob  => 1,
   clob  => 1,
   bytea  => 1,
);

sub _should_column_fetch {
   my ( $self, $column ) = @_;

   my $info = $self->result_source->column_info($column);

   if (!defined $info->{remove_column}) {
      if (defined $info->{data_type} &&
          $dont_fetch{lc $info->{data_type}}
      ) {
         $info->{remove_column} = 1;
      } else {
         $info->{remove_column} = 0;
      }
   }

   return $info->{remove_column};
}

sub fetchable_columns {
   my $self = shift;
   if (!$self->_fetchable_columns) {
     $self->_fetchable_columns([
        grep $self->_should_column_fetch($_),
           $self->result_source->columns
      ]);
   }
   return $self->_fetchable_columns;
}

sub _resolved_attrs {
   local $_[0]->{attrs}{remove_columns} =
      $_[0]->{attrs}{remove_columns} || $_[0]->fetchable_columns;

   return $_[0]->next::method;
}

1;

=pod

=head1 SYNOPSIS

 package MySchema::Result::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class::Core';

 __PACKAGE__->table('KittenRobot');
 __PACKAGE__->add_columns(
    id => {
       data_type         => 'integer',
       is_auto_increment => 1,
    },
    kitten => {
       data_type         => 'integer',
    },
    robot => {
       data_type         => 'text',
       is_nullable       => 1,
    },
    your_mom => {
       data_type         => 'blob',
       is_nullable       => 1,
       remove_column     => 0,
    },
 );

 1;

 package MySchema::ResultSet::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::ResultSet::AutoRemoveColumns');

=head1 DESCRIPTION

This component automatically removes "heavy-weight" columns.  To be specific,
columns of type C<text>, C<ntext>, C<blob>, C<clob>, or C<bytea>.  You may
use the C<remove_column> key in the column info to specify directly whether or
not to remove the column automatically. See
L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to your
entire schema.

=method _should_column_fetch

 $self->_should_column_fetch('kitten')

returns true if a column should be fetched or not.  This fetches a column if it
is not of type C<text>, C<ntext>, C<blob>, C<clob>, or C<bytea> or the
C<remove_column> is set to true.  If you only wanted to explicitly state which
columns to remove you might override this method like this:

 sub _should_column_fetch {
    my ( $self, $column ) = @_;

    my $info = $self->column_info($column);

    return !defined $info->{remove_column} || $info->{remove_column};
 }

=method fetchable_columns

simply returns a list of columns that are fetchable.
