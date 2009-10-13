package DBIx::Class::Helper::SubClass;

use strict;
use warnings;

sub subclass {
   my $self = shift;
   my $namespace = shift;
   $self->set_table;
   $self->generate_relationships($namespace);
}

sub generate_relationships {
   my $self = shift;
   my $namespace = shift;
   foreach my $rel ($self->relationships) {
      my $rel_info = $self->relationship_info($rel);
      my $class = $rel_info->{class};
      $self->add_relationship(
         $rel,
         $class,
         $rel_info->{cond},
         $rel_info->{attrs}
      );
   };
}

sub set_table {
   my $self = shift;
   $self->table($self->table);
}

1;

=pod

=head1 SYNOPSIS

=head1 DESCRIPTION

This component is to allow simple subclassing of L<DBIx::Class> Result classes.
Unfortunately, the parent classes are "Abstract" in that they can't be used on
their own without a little bit of extra work.

=head1 METHODS

=head2 subclass

This is probably the method you want.  You call this in your child class and it
"imports" the definitions from the parent into itself.

=head2 generate_relationships
=head2 set_table

This is a super basic method that just sets the current classes table to the
parent classes table.

=end
