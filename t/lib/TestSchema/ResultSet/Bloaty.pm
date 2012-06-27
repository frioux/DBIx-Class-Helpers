package TestSchema::ResultSet::Bloaty;
use strict;
use warnings;

use parent 'TestSchema::ResultSet';

__PACKAGE__->load_components(qw{
   Helper::ResultSet::AutoRemoveColumns
});

our @stuff;

sub update {
   my ($self, $rest) = @_;

   push @stuff, $rest;

   $self->next::method($rest);
}

1;
