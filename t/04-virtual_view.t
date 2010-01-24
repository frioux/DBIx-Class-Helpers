#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Exception;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();

my $new_rs = $schema->resultset('Foo')->search({
   'bar.foo_id' => 1
}, {
   join => 'bar'
});
lives_ok { $new_rs->count } 'regular search works';
lives_ok { $new_rs->search({'bar.id' => 1})->count }
   '... and chaining off that using join works';
lives_ok { $new_rs->search({'bar.id' => 1})->as_virtual_view->count }
   '... and chaining off the virtual view works';
dies_ok  { $new_rs->as_virtual_view->search({'bar.id' => 1})->count }
   q{... but chaining off of a virtual view using join doesn't work};
done_testing;
