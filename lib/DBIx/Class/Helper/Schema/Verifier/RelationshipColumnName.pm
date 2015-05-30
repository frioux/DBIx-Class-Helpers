package DBIx::Class::Helper::Schema::Verifier::RelationshipColumnName;

# ABSTRACT: Verify that relationships and column names are distinct

use strict;
use warnings;

use MRO::Compat;
use mro 'c3';

use base 'DBIx::Class::Helper::Schema::Verifier';

sub result_verifiers {
   (
      sub {
         my ($s, $result) = @_;

         my @columns = $result->columns;
         my %relationships = map { $_ => 1 } $result->relationships;

         my @mistakes = grep { $relationships{$_} } @columns;


         my $exp = 'See DBIx::Class::Helper::Schema::Verifier::RelationshipColumnName for more details';
         if (@mistakes == 1) {
            die "$result has a relationship name that is the same as a column name: @mistakes, $exp"
         } elsif (@mistakes) {
            die "$result has relationship names that are the same as column names: @mistakes, $exp"
         }
      },
      shift->next::method,
   )
}

1;

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::Verifier::RelationshipColumnName');

=head1 DESCRIPTION

C<DBIx::Class::Helper::Schema::Verifier::RelationshipColumnName> verifies that
none of your columns have the same name as a relationship.  If you create a
relationship that has the same name as a column, to access the column you will
be forced to use C<get_column>, additionally it is just confusing having them
be the same name.  What I tend to do is define the columns to be something like
C<user_id> and have the relationship then be simply C<user>.
