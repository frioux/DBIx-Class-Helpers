package VerifySchema;

use strict;
use warnings;

use MRO::Compat;
use mro 'c3';

use parent 'DBIx::Class::Schema';

# ensure that we can see both errors for a single check
sub result_verifiers {
   (sub {
      my ($s, $result, $set) = @_;

      die "Derp: $set" if $set->isa('Herp');
   }, sub {
      my ($s, $result, $set) = @_;

      die "Herp: $set" if $set->isa('Herp');
   }, shift->next::method)
}

__PACKAGE__->load_components(qw(
   Helper::Schema::Verifier
));

__PACKAGE__->load_namespaces;

'zomg';
