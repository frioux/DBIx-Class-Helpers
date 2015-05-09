package DBIx::Class::Helper::Schema::Verifier::Parent;

# ABSTRACT: Verify that the Results and ResultSets have the correct base class

use strict;
use warnings;

use MRO::Compat;
use mro 'c3';

use base 'DBIx::Class::Helper::Schema::Verifier';

sub result_verifiers {
   (
      sub {
         my ($s, $result, $set) = @_;

         my $base_result = $s->base_result;
         my $base_set    = $s->base_resultset;

         die "$result is not a $base_result" unless $result->isa($base_result);
         die    "$set is not a $base_set"    unless    $set->isa($base_set);
      },
      shift->next::method,
   )
}

sub base_result    { 'DBIx::Class::Core'      }
sub base_resultset { 'DBIx::Class::ResultSet' }

1;

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::Verifier::Parent');

 sub base_result    { 'MyApp::Schema::Result'    }
 sub base_resultset { 'MyApp::Schema::ResultSet' }

=head1 DESCRIPTION

C<DBIx::Class::Helper::Schema::Verifier::Parent> verifies that all of your
results and resultsets use the base class that you specify.
