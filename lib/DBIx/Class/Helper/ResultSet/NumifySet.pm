package DBIx::Class::Helper::ResultSet::NumifySet;

sub _numify_fields {
   my ($self, $args) = @_;

   my $ci = $self->result_source->columns_info;
   my $storage = $self->storage;

   $args = {
      map {
         $_ => $storage->is_datatype_numeric($ci->{$_}{data_type})
            ? 0 + $args->{$_}
            : $args->{$_}
      }
   };
}

sub update {
   my ($self, $args) = @_;

   $args = $self->_numify_fields($args);
   $self->next::method($args)
}

sub new_result {
   my ($self, $args) = @_;

   $args = $self->_numify_fields($args);
   $self->next::method($args)
}

1;
