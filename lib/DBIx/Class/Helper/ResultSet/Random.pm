package DBIx::Class::Helper::ResultSet::Random;

use strict;
use warnings;

# ABSTRACT: Get random rows from a ResultSet

# VERSION

# this is ghetto
my %rand_order_by = (
   'DBIx::Class::Storage::DBI::SQLite'                     => 'RANDOM()',
   'DBIx::Class::Storage::DBI::mysql'                      => 'RAND()',
   'DBIx::Class::Storage::DBI::ODBC::Microsoft_SQL_Server' => 'NEWID()',
   'DBIx::Class::Storage::DBI::MSSQL'                      => 'NEWID()',
   'DBIx::Class::Storage::DBI::Pg'                         => 'RANDOM()',
   'DBIx::Class::Storage::DBI::Oracle'                     => 'dbms_random.value',
   'DBIx::Class::Storage::DBI::Sybase::MSSQL'                     => 'NEWID()',
   'DBIx::Class::Storage::DBI::Sybase::Microsoft_SQL_Server::NoBindVars' =>
     'NEWID()',
   'DBIx::Class::Storage::DBI::Sybase::Microsoft_SQL_Server'      => 'NEWID()',
   'DBIx::Class::Storage::DBI::Sybase::ASE::NoBindVars'           => 'RAND()',
   'DBIx::Class::Storage::DBI::Sybase::ASE'                       => 'RAND()',
   'DBIx::Class::Storage::DBI::Sybase'                            => 'RAND()',
   'DBIx::Class::Storage::DBI::SQLAnywhere'                       => 'RAND()',
   'DBIx::Class::Storage::DBI::Oracle::WhereJoins' => 'dbms_random.value',
   'DBIx::Class::Storage::DBI::Oracle::Generic'    => 'dbms_random.value',
   'DBIx::Class::Storage::DBI::ODBC::SQL_Anywhere' => 'RAND()',
   'DBIx::Class::Storage::DBI::ODBC::Firebird'                    => 'RAND()',
   'DBIx::Class::Storage::DBI::ODBC::ACCESS'                      => 'RND()',
   'DBIx::Class::Storage::DBI::mysql::backup'                     => 'RAND()',
   'DBIx::Class::Storage::DBI::InterBase'                         => 'RAND()',
   'DBIx::Class::Storage::DBI::Firebird::Common'                  => 'RAND()',
   'DBIx::Class::Storage::DBI::Firebird'                          => 'RAND()',
   'DBIx::Class::Storage::DBI::DB2'                               => 'RAND()',
   'DBIx::Class::Storage::DBI::ADO::MS_Jet'                       => 'RND()',
   'DBIx::Class::Storage::DBI::ADO::Microsoft_SQL_Server'         => 'NEWID()',
   'DBIx::Class::Storage::DBI::ACCESS'                            => 'RND()',
);

{
#sort keys descending to handle more specific storage classes first
#(right now it does not make a difference though)
my @keys_rand_order_by = sort { $b cmp $a } keys %rand_order_by;

sub _rand_order_by {
   my $self = shift;
   $self->result_source->storage->_determine_driver;
   my $storage = $self->result_source->storage;

   for my $dbms (@keys_rand_order_by) {
      return $rand_order_by{$dbms} if $storage->isa($dbms);
   }

   return 'RAND()';
}
}

sub rand {
   my $self   = shift;
   my $amount = shift || 1;

   $self->throw_exception('rand can only return a positive amount of rows')
      unless $amount > 0;

   $self->throw_exception('rand can only return an integer amount of rows')
      unless $amount == int $amount;

   my $order_by = $self->_rand_order_by;

   return $self->search(undef, { rows=> $amount, order_by => \$order_by});
}

1;

=pod

=head1 SYNOPSIS

 # note that this is normally a component for a ResultSet
 package MySchema::ResultSet::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::ResultSet::Random');

 # in code using resultset:
 my $random_row  = $schema->resultset('Bar')->rand->single;

=head1 DESCRIPTION

This component allows convenient selection of random rows.  See
L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to your
entire schema.

Currently this works by doing something akin to

 SELECT TOP($x) from $table ORDER BY RANDOM()

Lots of people think this is slow.  My own benchmarks show that doing the above,
for 10 rows in a table with just over 8 million rows, is nearly instant.
Although that was with SQL Server, and different databases will handle that
differently.

So please, if you have performance issues and want this to work with your
database, get in touch and I will do what I can to get it to work quickly enough
to suite your needs.

=head1 METHODS

=head2 rand

This method takes a single argument, being the size of the random ResultSet
to return.  It defaults to 1.  This Component will throw exceptions if the
argument is not an integer or not greater than zero.

=head2 _rand_order_by

This module currently does an C<ORDER BY> on some db specific function.  If for
some reason it guesses incorrectly for your database the easiest way to fix
that in the short-term (ie without patching upstream) is to override this
method.  So for example, if your db uses C<RAND()> instead of C<RANDOM()> and
it's not in the predefined list of dbs you could just do the following in your
ResultSet class:

 sub _rand_order_by { 'RAND()' }
