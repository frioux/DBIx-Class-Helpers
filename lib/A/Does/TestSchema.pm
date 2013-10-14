package A::Does::TestSchema;

use Moo::Role;
use lib 't/lib';
use TestSchema;

has schema => (
   is => 'ro',
   lazy => 1,
   builder => 'build_schema',
   clearer => 'reset_schema',
);

sub build_schema {
   my $schema = TestSchema->deploy_or_connect();
   $schema->prepopulate unless $_[0]->can('no_deploy');
   $schema
}

1;
