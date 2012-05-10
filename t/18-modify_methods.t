use strict;
use warnings;

use lib 't/lib';
use Test::More;
use TestSchema;

my ($around, $before, $after) = (0,0,0);
my $schema = TestSchema->deploy_or_connect;

ok $schema->prepopulate;

ok my $rs = $schema
  ->resultset('Foo')
  ->around('search', sub {
    my ($orig, $self, @args) = @_;
    ok $before, 'Before was set';
    ok !$after, 'After not yet set';
    $around = 1;
    $self->$orig(@args);
  })
  ->before('search', sub {
    my ($self, @args) = @_;
    $before = 1;
    ok !$after, 'After not yet set';
    ok !$around, 'Around not was set';
  })
  ->after(['search', 'find'], sub {
    my ($self, @args) = @_;
    ok !$after, 'After not yet set';
    $after = 1;
    ok $before, 'Before was set';
    ok $around, 'Around was set';
  })
  ->search({id=>[1,2]}),
  'Got a good resultset';

ok $rs->count, 'Got back to original set';
ok $around, 'Around Flag was set';
ok $before, 'Before Flag was set';
ok $after, 'After Flag was set';

## Need explicit test number here to make sure we don't have too many modifier
## callbacks fired off.  If you change these tests please keep up-to-date.

done_testing(13);

