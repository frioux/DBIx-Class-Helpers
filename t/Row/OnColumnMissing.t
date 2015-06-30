#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Fatal 'exception';;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $row = $schema->resultset('Gnarly')
   ->search(undef, { columns => ['id'] })
   ->one_row;

ok($row->id, 'row loaded');

{
   my $warning;
   local $SIG{__WARN__} = sub { $warning = shift };
   $row->literature;

   like($warning, qr/Column literature has not been loaded/, 'warnings');
};

{
   local $TestSchema::Result::Gnarly::MISSING = 'die';
   my $e = exception { $row->literature };

   like($e, qr/Column literature has not been loaded/, 'exceptions');
};

{
   local $TestSchema::Result::Gnarly::MISSING = 'nothing';
   $row->literature;

   ok 1, 'nothing?';
};

{
   my $custom;
   local $TestSchema::Result::Gnarly::MISSING = sub { $custom = $_[1] };
   $row->literature;

   is($custom, 'literature', 'custom action');
};

done_testing;
