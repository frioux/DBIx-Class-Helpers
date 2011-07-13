use strict;
use warnings;

use lib 't/lib';
use Test::More;
use TestSchema;

ok my $schema = TestSchema->deploy_or_connect();
ok $schema->prepopulate;

my $flag = 0;
ok my $rs = $schema
  ->resultset('Foo')
  ->around('search', sub {
    my ($orig, $self, @args) = @_;
    $flag=1;
    $self->$orig(@args);
  })
  ->search({id=>[1,2]})
  ->do(sub {
    my $rs = shift;
    is $rs->next->id, 1;
    is $rs->next->id, 2;
    ok !$rs->next, 'correctly found the end of the set';
  });

ok $rs->count, 'Got back to original set';
ok $flag, 'Flag was set';

done_testing

