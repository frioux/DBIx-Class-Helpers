package DBIx::Class::Helper::Schema::Verifier::C3;

# ABSTRACT: Verify that the Results and ResultSets of your Schemata use c3

use strict;
use warnings;

use MRO::Compat;
use mro 'c3';

use base 'DBIx::Class::Helper::Schema::Verifier';

sub result_verifiers {
   (
      sub {
         my ($s, $result, $set) = @_;

         for ($result, $set) {
            my $mro = mro::get_mro($_);
            die "$_ does not use c3, it uses $mro" unless $mro eq 'c3';
         }
      },
      shift->next::method,
   )
}

1;

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::Verifier::C3');

=head1 DESCRIPTION

C<DBIx::Class::Helper::Schema::Verifier::C3> verifies that all of your results
and resultsets use the C<c3> C<mro>.  If you didn't know this was important
L<you know now|https://blog.afoolishmanifesto.com/posts/mros-and-you>.  Note:
this will probably fail on  your schema because L<DBIx::Class::ResultSet> does
not use C<c3>.
