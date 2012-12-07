package TestSchema::ResultSet::Gnarly;
use strict;
use warnings;

# intentionally not using TestSchema::ResultSet
use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw{ Helper::ResultSet::Me Helper::ResultSet::ResultClassDWIM Helper::ResultSet::CorrelateRelationship Helper::ResultSet::SearchOr Helper::ResultSet::NoColumns });

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
