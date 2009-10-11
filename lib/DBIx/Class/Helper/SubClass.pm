package DBIx::Class::Helper::SubClass;

sub subclass {
   my $self = shift;
   my $namespace = shift;
   $self->set_table;
   $self->generate_relationships($namespace);
}

sub generate_relationships {
   my $self = shift;
   my $namespace = shift;
   foreach my $relationship_type (keys %{$self->relationship_definitions}) {
      foreach my $relationship (@{$self->relationship_definitions->{$relationship_type}}) {
         if ($relationship->[1] =~ m/^::/ ) {
            $relationship->[1] = $namespace.$relationship->[1];
         }
         $self->$relationship_type(@{$relationship});
      }
   }
}

sub set_table {
   my $self = shift;
   $self->table($self->table);
}

1;

=pod

=head1 SYNOPSIS

=head1 METHODS

=head2 subclass
=head2 generate_relationships
=head2 set_table
=end
