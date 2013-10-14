#!perl

use lib 't/lib';
use Test::Deep 'cmp_deeply';
use Test::Roo;
with 'A::Does::TestSchema';

test 'simple json' => sub {
   my $schema = shift->schema;
   my $datas = [
      map $_->TO_JSON,
         $schema->resultset('Bar')->search(undef, { order_by => 'id' })->all
      ];

   cmp_deeply($datas, [{
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
};

test 'complex json' => sub {
   my $schema = shift->schema;
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
};

run_me;
done_testing;
