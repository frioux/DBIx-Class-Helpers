package DBIx::Class::Helper::ResultSet::Explain;

# ABSTRACT: Get query plan for a ResultSet

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

use DBIx::Introspector;

sub _introspector {
   my $d = DBIx::Introspector->new(drivers => '2013-12.01');

   $d->decorate_driver_connected(MSSQL => splain => 'GETUTCDATE()');
   $d->decorate_driver_connected(
      SQLite => splain => sub {
         sub {
            my ($dbh, $query) = @_;
            my ($sql, @bind)  = @{$$query};

            $sql =~ s/\s*\((.*)\)\s*/$1/;

            shift->selectall_arrayref("EXPLAIN $sql", undef, @bind)
         },
      },
   );
   $d->decorate_driver_connected(
      Pg => splain => sub {
         sub {
            my ($dbh, $query) = @_;
            my ($sql, @bind)  = @{$$query};
            shift->selectall_arrayref("EXPLAIN ANALYZE $sql", undef, @bind)
         },
      },
   );

   $d->decorate_driver_connected(
      mysql => splain => sub {
         sub {
            my ($dbh, $query) = @_;
            my ($sql, @bind)  = @{$$query};
            shift->selectall_arrayref("EXPLAIN EXTENDED $sql", undef, @bind)
         },
      },
   );

   return $d;
}

use namespace::clean;

my $i;

sub explain {
   $i ||= _introspector();

   my $self = shift;

   my $storage = $self->result_source->storage;
   $storage->ensure_connected;
   my $dbh = $storage->dbh;

   $i->get($dbh, undef, 'splain')->($dbh, $self->as_query)
}

1;

__END__

=pod

=head1 SYNOPSIS

This module mostly makes sense to be used without setting as a component:

 use Devel::Dwarn;
 Dwarn DBIx::Class::ResultSet::Explain::explain($rs)

But as usual, if you prefer to use it as a component here's how:

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::ResultSet::Explain});

 ...

 1;

And then in a script or something:

 use Devel::Dwarn;
 Dwarn $rs->explain;

=head1 DESCRIPTION

This is just a handy little tool that gives you the query plan for a given
ResultSet.  The output is in no way normalized, so just treat it as a debug tool
or something.  The only supported DB's are those listed below.  Have fun!

See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it
to your entire schema.

=head1 EXAMPLE OUTPUT FROM SUPPORTED DB's

=head2 SQlite

=for exec
perl maint/explain-out SQLite

=head2 Pg

=for exec
perl maint/explain-out Pg

=head2 mysql

=for exec
perl maint/explain-out mysql
