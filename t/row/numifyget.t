#!perl

use lib 't/lib';
use Test::Exception;
use List::Util 'first';
use Test::Roo;
with 'A::Does::TestSchema';

use B;

# stolen from JSON::PP
sub is_numeric {
   my $value = shift;
   my $b_obj = B::svref_2object(\$value);
   my $flags = $b_obj->FLAGS;
   return (( $flags & B::SVf_IOK or $flags & B::SVp_IOK
          or $flags & B::SVf_NOK or $flags & B::SVp_NOK
        ) and !($flags & B::SVf_POK ))
}

test foo => sub {
   my $schema = shift->schema;
   ok(is_numeric($schema->resultset('Foo')->first->bar_id),"bar_id has been 'numified' w/o is_numeric set");

   for (map $_->id, $schema->resultset('Foo')->all) {
      ok(is_numeric($_), "id $_ has been 'numified'");
   }

   for (map +{$_->get_columns}, $schema->resultset('Foo')->all) {
      ok(is_numeric($_->{id}), "id $_->{id} has been 'numified'");
   }

   for (map +{$_->get_inflated_columns}, $schema->resultset('Foo')->all) {
      ok(is_numeric($_->{id}), "id $_->{id} has been 'numified'");
   }

   for (map +{$_->get_inflated_columns}, $schema->resultset('Foo')->all) {
      ok(is_numeric($_->{id}), "id $_->{id} has been 'numified'");
   }

   for ($schema->resultset('Foo')->search(undef, {
      columns => { lol => 'id' },
   })->all) {
      lives_ok { $_->get_column('lol') } "doesn't break when using columns";
   }
};

run_me;
done_testing;
