#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;

use DBIx::Class::Helper::ResultClass::Tee;

my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Gnarly')->search(undef, {
   result_class => DBIx::Class::Helper::ResultClass::Tee->new(
      inner_classes => ['::HRI', 'TestSchema::Result::Gnarly'],
   )
});

my $arr = $rs->first;

cmp_deeply($arr->[0], superhashof({
   name => "frew",
}), '::HRI');

is($arr->[1]->name, 'frew', 'TestSchema::Result::Gnarly');

done_testing;
