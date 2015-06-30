package TestSchema::ResultSet::Gnarly;
use strict;
use warnings;

# intentionally not using TestSchema::ResultSet
use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw{
   Helper::ResultSet::CorrelateRelationship
   Helper::ResultSet::Errors
   Helper::ResultSet::Explain
   Helper::ResultSet::Me
   Helper::ResultSet::NoColumns
   Helper::ResultSet::OneRow
   Helper::ResultSet::ResultClassDWIM
   Helper::ResultSet::SearchOr
});

sub with_id_plus_one {
   my $self = shift;
   my $id = $self->me . 'id';
   $self->search(undef, {
      '+columns' => {
         id_plus_one => \"$id + 1",
      },
   })
}

sub id_plus_two {
   my $self = shift;
   my $id = $self->me . 'id';
   $self->search(undef, {
      '+columns' => {
         plus2 => \"$id + 2",
      },
   })
}

1;
