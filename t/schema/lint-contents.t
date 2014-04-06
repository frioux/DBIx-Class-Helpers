#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;

subtest 'null_check_source_auto' => sub {
   my $schema = TestSchema->deploy_or_connect();
   $schema->prepopulate;

   local $schema->source('Gnarly')->column_info('literature')->{is_nullable} = 0;
   cmp_deeply [map +{ $_ => $schema->null_check_source_auto($_)->count }, sort $schema->sources], supersetof(
     { Bar => 0 },
     { Bloaty => 0 },
     { Foo => 0 },
     { Foo_Bar => 0 },
     { Gnarly => 3 },
     { Gnarly_Station => 0 },
     { Station => 0 },
   ), 'errors for Gnarly null_check_source';
};

subtest 'dub_check_source_auto' => sub {
   my $schema = TestSchema->deploy_or_connect();
   $schema->prepopulate;

   $schema->resultset('Gnarly')->create({ id => 100 + $_, name => 'foo' }) for 1, 2;
   $schema->resultset('Gnarly')->create({ id => 200 + $_, name => 'bar' }) for 1, 2;
   $schema->source('Gnarly')->add_unique_constraint(['name']);

   cmp_deeply [map {
      my $source = $_;
      my $constraints = $schema->dup_check_source_auto($source);
      map {
         my $constraint_name = $_;
        +{ "$source $constraint_name" => $constraints->{$constraint_name}->count }
      } sort keys %$constraints;
   } grep { $_ ne 'Bloaty' } sort $schema->sources], supersetof(
     { "Bar primary" => 0 },
     { "Foo primary" => 0 },
     { "Foo_Bar primary" => 0 },
     { "Gnarly Gnarly_name" => 2 },
     { "Gnarly primary" => 0 },
     { "Gnarly_Station primary" => 0 },
     { "Station primary" => 0 },
   ), 'Gnarly_name duplicated twice';
};

subtest 'fk_check_source_auto' => sub {
   my $schema = TestSchema->deploy_or_connect();
   $schema->prepopulate;

   $schema->resultset('Foo_Bar')->delete;
   $schema->resultset('Foo_Bar')->create({
      foo_id => 1010,
      bar_id => 2020,
   });
   $schema->resultset('Foo_Bar')->create({
      foo_id => 1111,
      bar_id => 2222,
   });

   cmp_deeply [map {
      my $source = $_;
      my $constraints = $schema->fk_check_source_auto($source);
      map {
         my $fk_constraint_name = $_;
        +{ "$source $fk_constraint_name" => $constraints->{$fk_constraint_name}->count }
      } sort keys %$constraints;
   } grep { $_ ne 'Bloaty' } sort $schema->sources], supersetof(
     { "Bar foo" => 0 },
     { "Foo bar" => 0 },
     { "Foo_Bar bar" => 2 },
     { "Foo_Bar foo" => 2 },
     { "Gnarly_Station gnarly" => 0 },
     { "Gnarly_Station station" => 0 },
   ), 'foo and bar constraints broken';
};

done_testing;
