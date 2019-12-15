#!perl

use Test::Roo;
use Test::Fatal;
use Data::Dumper::Concise;

use lib 't/lib';

with 'A::Role::TestConnect';

sub rs { shift->schema->resultset('Gnarly') }

my $ran;
top_test basic => sub {
   my $self = shift;
   my $rs = $self->rs;
   SKIP: {
      skip 'cannot test without a connection', 1 unless $self->connected;
      $ran++ if $self->engine eq 'SQLite';

      my $s;
      my $e = exception { $s = $rs->explain };
      ok(!$e, 'valid SQL') or diag $e;
      note(Dumper($s)) if $s;
   }
};

run_me(SQLite => {
   engine => 'SQLite',
   connect_info => [ 'dbi:SQLite::memory:'],
});
run_me(Pg     => { engine => 'Pg'     });
run_me(mysql  => { engine => 'mysql'  });

ok $ran, 'tests were run against default SQLite';
done_testing;
