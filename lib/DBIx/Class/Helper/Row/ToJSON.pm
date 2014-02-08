package DBIx::Class::Helper::Row::ToJSON;

use strict;
use warnings;

use parent 'DBIx::Class';

# ABSTRACT: Remove the boilerplate from your TO_JSON functions

__PACKAGE__->mk_group_accessors(inherited => '_serializable_columns');

my $dont_serialize = {
   text  => 1,
   ntext => 1,
   blob  => 1,
};

sub _is_column_serializable {
   my ( $self, $column ) = @_;

   my $info = $self->column_info($column);

   if (!defined $info->{is_serializable}) {
      if (defined $info->{data_type} &&
          $dont_serialize->{lc $info->{data_type}}
      ) {
         $info->{is_serializable} = 0;
      } else {
         $info->{is_serializable} = 1;
      }
   }

   return $info->{is_serializable};
}

sub serializable_columns {
   my $self = shift;
   if (!$self->_serializable_columns) {
     $self->_serializable_columns([
        grep $self->_is_column_serializable($_),
           $self->result_source->columns
      ]);
   }
   return $self->_serializable_columns;
}

sub TO_JSON {
   my $self = shift;

   return {
      map +($_ => $self->$_),
         @{$self->serializable_columns}
   };
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::Result::KittenRobot;

 use base 'DBIx::Class::Core';

 __PACKAGE__->load_components(qw{Helper::Row::ToJSON});

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
       is_serializable   => 1,
    },
 );

 1;

This helper adds a JSON method like the following:

 sub TO_JSON {
    return {
       id       => $self->id,
       kitten   => $self->kitten,
       # robot  => $self->robot,    # <-- doesn't serialize text columns
       your_mom => $self->your_mom, # <-- normally wouldn't but explicitly
                                    #     asked for in the column spec above
    }
 }

=method _is_column_serializable

 $self->_is_column_serializable('kitten')

returns true if a column should be serializable or not.  Currently this marks
everything as serializable unless C<is_serializable> is set to false, or
C<data_type> is a C<blob>, C<text>, or C<ntext> columns.  If you wanted to only
have explicit serialization you might override this method to look like this:

 sub _is_column_serializable {
    my ( $self, $column ) = @_;

    my $info = $self->column_info($column);

    return defined $info->{is_serializable} && $info->{is_serializable};
 }

=method serializable_columns

 $self->serializable_columns

simply returns a list of columns that TO_JSON should serialize.

=method TO_JSON

 $self->TO_JSON

returns a hashref representing your object.  Override this method to add data
to the returned hashref:

 sub TO_JSON {
    my $self = shift;

    return {
       customer_name => $self->customer->name,
       %{ $self->next::method },
    }
 }
