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

   $schema->source('Gnarly')->column_info('literature')->{is_nullable} = 0;
   cmp_deeply [map +{ $_ => $schema->null_check_source_auto($_)->count }, $schema->sources], [
     { Gnarly => 3 },
     { Bar => 0 },
     { Station => 0 },
     { Foo_Bar => 0 },
     { Bloaty => undef },
     { Foo => 0 },
     { Gnarly_Station => 0 }
   ], 'errors for Gnarly null_check_source';
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
      } keys %$constraints;
   } grep { $_ ne 'Bloaty' } $schema->sources], [
     { "Gnarly Gnarly_name" => 2 },
     { "Gnarly primary" => 0 },
     { "Bar primary" => 0 },
     { "Station primary" => 0 },
     { "Foo_Bar primary" => 0 },
     { "Foo primary" => 0 },
     { "Gnarly_Station primary" => 0 }
   ], 'Gnarly_name duplicated twice';
};

subtest 'fk_check_source_auto' => sub {
   my $schema = TestSchema->deploy_or_connect();
   $schema->prepopulate;

   $schema->resultset('Foo_Bar')->delete;
   $schema->resultset('Foo_Bar')->create({
      foo_id => 1010,
      bar_id => 2020,
   });

   cmp_deeply [map {
      my $source = $_;
      my $constraints = $schema->fk_check_source_auto($source);
      map {
         my $fk_constraint_name = $_;
        +{ "$source $fk_constraint_name" => $constraints->{$fk_constraint_name}->count }
      } keys %$constraints;
   } grep { $_ ne 'Bloaty' } $schema->sources], [
     { "Bar foo" => 0 },
     { "Foo_Bar bar" => 1 },
     { "Foo_Bar foo" => 1 },
     { "Foo bar" => 0 },
     { "Gnarly_Station station" => 0 },
     { "Gnarly_Station gnarly" => 0 }
   ], 'foo and bar constraints broken';
};

done_testing;
