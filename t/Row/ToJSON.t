#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

SIMPLE_JSON: {
   my $datas = [
      map $_->TO_JSON,
         $schema->resultset('Bar')->search(undef, { order_by => 'id' })->all
      ];

   cmp_deeply($datas, [map superhashof($_), {
         id => 1,
         foo_id => 1,
      },{
         id => 2,
         foo_id => 2,
      },{
         id => 3,
         foo_id => 3,
      },{
         id => 4,
         foo_id => 4,
      },{
         id => 5,
         foo_id => 5,
   }], 'simple TO_JSON works');
}

MORE_COMPLEX_JSON: {
   my $datas = [
      map $_->TO_JSON,
         $schema->resultset('Gnarly')->search(undef, { order_by => 'id' })->all
      ];

   cmp_deeply($datas, [{
         id => 1,
         name => 'frew',
         your_mom => undef,
      },{
         id => 2,
         name => 'frioux',
         your_mom => undef,
      },{
         id => 3,
         name => 'frooh',
         your_mom => undef,
   }], 'complex TO_JSON works');
}

ACCESSOR_CLASS: {
   my $datas = [
      map $_->TO_JSON,
         $schema->resultset('HasAccessor')->search(undef, { order_by => 'id' })->all
      ];

   cmp_deeply($datas, [{
         id => 1,
         usable_column => 'aa',
         alternate_name => 'bb',
      },{
         id => 2,
         usable_column => 'cc',
         alternate_name => 'dd',
      },{
         id => 3,
         usable_column => 'ee',
         alternate_name => 'ff',
   }], 'accessor fields with TO_JSON works');
}

SERIALIZE_ALL_DATA_TYPES: {
   my $datas = [
      map $_->TO_JSON,
         $schema->resultset('SerializeAll')->search(undef, { order_by => 'id' })->all
      ];

   cmp_deeply($datas, [{
         id => 1,
         text_column => 'frew',
      },{
         id => 2,
         text_column => 'frioux',
      },{
         id => 3,
         text_column => 'frooh',
   }], 'serialize all data types with TO_JSON');
}

done_testing;
