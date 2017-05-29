package A::Role::TestConnect;

use Moo::Role;
use TestSchema;

use A::Util;

has [qw(on_connect_call engine)] => ( is => 'ro' );

has storage_type => (
   is => 'ro',
   lazy => 1,
   default => sub { shift->engine }
);

sub connected { A::Util::connected($_[0]->engine, $_[0]->on_connect_call) }

sub env_vars { A::Util::env(shift->engine) }

has schema => (
   is => 'ro',
   lazy => 1,
   builder => sub {
      my $self = shift;

      A::Util::connect($self->engine, $self->storage_type, $self->on_connect_call)
   },
);

1;
