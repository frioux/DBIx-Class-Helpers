package VerifySchema;

use strict;
use warnings;

use MRO::Compat;
use mro 'c3';

use parent 'DBIx::Class::Schema';

sub result_verifiers {
   (sub {
      my ($s, $result, $set) = @_;

      die 'Derp' if $set->isa('Herp');
   }, shift->next::method)
}

__PACKAGE__->load_components(qw(
   Helper::Schema::Verifier
));

__PACKAGE__->load_namespaces;

'zomg';
