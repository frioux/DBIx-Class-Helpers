package DBIx::Class::Helper::Row::StorageValues;

# ABSTRACT: Keep track of stored vs in-memory row values

use strict;
use warnings;

use parent 'DBIx::Class::Row';

__PACKAGE__->mk_group_accessors(inherited => '_storage_value_columns');
__PACKAGE__->mk_group_accessors(inherited => '_storage_values');

sub _has_storage_value { $_[0]->column_info($_[1])->{keep_storage_value} }

sub storage_value_columns {
   my $self = shift;
   if (!$self->_storage_value_columns) {
     $self->_storage_value_columns([
        grep $self->_has_storage_value($_),
           $self->result_source->columns
     ]);
   }
   return $self->_storage_value_columns;
}

sub store_storage_values {
   my $self = shift;
   $self->_storage_values({
      map {
         my $acc = ($self->column_info($_)->{accessor} || $_);
         $_ => $self->$acc
      } @{$self->storage_value_columns}
   });
   $self->_storage_values;
}

sub get_storage_value { $_[0]->_storage_values->{$_[1]} }

sub new {
   my $class = shift;
   my $ret = $class->next::method(@_);
   $ret->store_storage_values;
   $ret;
}

sub inflate_result {
   my $class = shift;
   my $ret = $class->next::method(@_);
   $ret->store_storage_values;
   $ret;
}

sub insert {
   my $self = shift;
   my $ret = $self->next::method(@_);
   $ret->store_storage_values;
   $ret;
}

sub update {
   my $self = shift;
   my $ret = $self->next::method(@_);
   $ret->store_storage_values;
   $ret;
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::Result::BlogPost;

 use parent 'DBIx::Class::Core';

 __PACKAGE__->load_components(qw(Helper::Row::StorageValues));

 __PACKAGE__->table('BlogPost');
 __PACKAGE__->add_columns(
    id => {
       data_type         => 'integer',
       is_auto_increment => 1,
    },
    title => {
       data_type          => 'varchar',
       length             => 32,
       keep_storage_value => 1,
    },
    body => {
       data_type => 'text',
    },
 );

 1;

 # elsewhere:

 my $post = $blog_rs->create({
   title => 'Components for fun and profit',
   body  => '...',
 });

 $post->title('Components for fun');

 warn sprintf 'Changing title from %s to %s',
   $post->storage_value('title'), $post->title;

 $post->update;

=head1 DESCRIPTION

This component keeps track of the value for a given column in the database.  If
you change the column's value and do not call C<update>, the C<storage_value>
will be different; once C<update> is called the C<storage_value> will be set
to the value of the accessor.  Note that the fact that it uses the accessor is
an important distinction.  If you are using L<DBIx::Class::FilterColumn> or
L<DBIx::Class::InflateColumn> it will get the non-storage or inflated values,
respectively.

=method _has_storage_value

 $self->_has_storage_value('colname')

returns true if we should store the storage value from the database.  Override
this if you'd like to enable storage on all integers or something like that:

 sub _has_storage_value {
    my ( $self, $column ) = @_;

    my $info = $self->column_info($column);

    return defined $info->{data_type} && $info->{data_type} eq 'integer';
 }

=method storage_value_columns

 $self->storage_value_columns

returns a list of columns to store

=method get_storage_value

 $self->get_storage_value('colname')

returns the value for that column which is in storage
