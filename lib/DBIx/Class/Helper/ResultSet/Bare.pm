package DBIx::Class::Helper::ResultSet::Bare;

# ABSTRACT: Get an unsearched ResultSet

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub bare { shift->result_source->resultset }

1;

__END__

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::KV;

 __PACKAGE__->load_components(qw{Helper::ResultSet::Bare});

 sub set_value {
    my ($self, $key, $value) = @_;

    $self->bare->create_or_update({
       key => $key,
       value => $value,
    });
 }

 1;

=head1 DESCRIPTION

Once in a blue moon you will find yourself in the frustrating position of
needing a vanilla ResultSet when all you have is a ResultSet that has a search
applied to it.  That's what this helper is for; it gives you a method to get at an
unsearched version of the ResultSet.

=head1 METHODS

=head2 C<bare>

 my $plain_rs = $searched_rs->bare;

Takes no arguments and returns the ResultSet as if nothing were searched against
it at all.
