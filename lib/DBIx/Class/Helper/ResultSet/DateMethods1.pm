package DBIx::Class::Helper::ResultSet::DateMethods1;

# ABSTRACT: Work with dates in your RDBMS nicely

use strict;
use warnings;

use DBIx::Introspector;
use Safe::Isa;

sub _flatten_thing {
   my ($self, $thing) = @_;

   die 'you dummy' unless defined $thing;
   my $ref = ref $thing;

   return ('?', $thing) if !$ref;

   if ($ref eq 'HASH' && exists $thing->{'-ident'}) {
      my $thing = $thing->{'-ident'};
      $thing = $self->current_source_alias . $thing if $thing =~ m/^\./;
      return $self->result_source->storage->sql_maker->_quote($thing)
   }

   return ${$thing} if $ref eq 'SCALAR';

   # FIXME: this should have the right bind type
   return ('?', $self->utc($thing)) if $thing->$_isa('DateTime');
   return @{${$thing}};
}

sub _introspector {
   my $d = DBIx::Introspector->new(drivers => '2013-12.01');

   $d->decorate_driver_unconnected(MSSQL => now_utc_sql => 'GETUTCDATE()');
   $d->decorate_driver_unconnected(SQLite => now_utc_sql => q<DATETIME('now')>);
   $d->decorate_driver_unconnected(mysql => now_utc_sql => 'UTC_TIMESTAMP()');
   $d->decorate_driver_unconnected(Oracle => now_utc_sql => 'sys_extract_utc(SYSTIMESTAMP)');
   $d->decorate_driver_unconnected(Pg => now_utc_sql => 'CURRENT_TIMESTAMP');
   MSSQL: {
      my %part_map = (
         year         => 'year',
         quarter      => 'quarter',
         month        => 'month',
         day_of_year  => 'dayofyear',
         day_of_month => 'day',
         week         => 'week',
         day_of_week  => 'ISO_WEEK',
         hour         => 'hour',
         minute       => 'minute',
         second       => 'second',
         millisecond  => 'millisecond',
         nanosecond   => 'nanosecond',
         non_iso_day_of_week => 'weekday',
         timezone_as_minutes => 'TZoffset',
      );

      $d->decorate_driver_unconnected(MSSQL => datepart_sql => sub {
         sub {
            my ($date_sql, $part) = @_;

            my $sql = delete $date_sql->[0];

            return [
               "DATEPART($part_map{$part}, $sql)",
               @$date_sql
            ]
         }
      });


      my %diff_part_map = %part_map;
      $diff_part_map{day} = delete $diff_part_map{day_of_year};
      delete $diff_part_map{day_of_month};
      delete $diff_part_map{day_of_week};

      $d->decorate_driver_unconnected(MSSQL => dateadd_sql => sub {
         sub {
            my ($date_sql, $unit, $amount_sql) = @_;

            my ($d_sql, @d_args) = @{$date_sql};
            my ($a_sql, @a_args) = @{$amount_sql};

            return [
               "DATEADD($diff_part_map{$unit}, CAST($a_sql AS int), $d_sql)",
               @a_args, @d_args,
            ];
         }
      });
   }

   SQLITE: {
      my %part_map = (
         month               => 'm',
         day_of_month        => 'd',
         year                => 'Y',
         hour                => 'H',
         day_of_year         => 'j',
         minute              => 'M',
         second              => 'S',
         day_of_week         => 'w',
         week                => 'W',
         # maybe don't support these or prefix them with 'sqlite.'?
         julian_day          => 'J',
         seconds_since_epoch => 's',
         fractional_seconds  => 'f',
      );

      $d->decorate_driver_unconnected(SQLite => datepart_sql => sub {
         sub {
            my ($date_sql, $part) = @_;

            my $sql = delete $date_sql->[0];

            return [
               "STRFTIME('%$part_map{$part}', $sql)",
               @$date_sql
            ]
         }
      });


      my %diff_part_map = (
         day                 => 'days',
         hour                => 'hours',
         minute              => 'minutes',
         second              => 'seconds',
         month               => 'months',
         year                => 'years',
      );

      $d->decorate_driver_unconnected(SQLite => dateadd_sql => sub {
         sub {
            my ($date_sql, $unit, $amount_sql) = @_;

            my ($d_sql, @d_args) = @{$date_sql};
            my ($a_sql, @a_args) = @{$amount_sql};

            die "unknown part $unit" unless $diff_part_map{$unit};

            return [
               "DATETIME($d_sql, $a_sql || ?)",
               @d_args, @a_args, " $diff_part_map{$unit}"
            ];
         }
      });
   }

   PG: {
      my %part_map = (
         century             => 'century',
         decade              => 'decade',
         day_of_month        => 'day',
         day_of_week         => 'dow',
         day_of_year         => 'doy',
         seconds_since_epoch => 'epoch',
         hour                => 'hour',
         iso_day_of_week     => 'isodow',
         iso_year            => 'isoyear',
         microsecond         => 'microseconds',
         millenium           => 'millenium',
         millisecond         => 'milliseconds',
         minute              => 'minute',
         month               => 'month',
         quarter             => 'quarter',
         second              => 'second',
         timezone            => 'timezone',
         timezone_hour       => 'timezone_hour',
         timezone_minute     => 'timezone_minute',
         week                => 'week',
         year                => 'year',
      );

      my %diff_part_map = %part_map;
      delete $diff_part_map{qw(
         day_of_week day_of_year iso_day_of_week iso_year millenium quarter
         seconds_since_epoch timezone timezone_hour timezone_minute
      )};
      $diff_part_map{day} = delete $diff_part_map{day_of_month};

      $d->decorate_driver_unconnected(Pg => datepart_sql => sub {
         sub {
            my ($date_sql, $part) = @_;

            my $sql = delete $date_sql->[0];

            return [
               "date_part(?, $sql)",
               $part_map{$part}, @$date_sql
            ]
         }
      });

      $d->decorate_driver_unconnected(Pg => dateadd_sql => sub {
         sub {
            my ($date_sql, $unit, $amount_sql) = @_;

            my ($d_sql, @d_args) = @{$date_sql};
            my ($a_sql, @a_args) = @{$amount_sql};

            die "unknown part $unit" unless $diff_part_map{$unit};

            return [
               "($d_sql + $a_sql * interval '1 $diff_part_map{$unit}')",
               @d_args, @a_args,
            ];
         }
      });
   }

   MYSQL: {
      my %part_map = (
         microsecond        => 'MICROSECOND',
         second             => 'SECOND',
         minute             => 'MINUTE',
         hour               => 'HOUR',
         day_of_month       => 'DAY',
         week               => 'WEEK',
         month              => 'MONTH',
         quarter            => 'QUARTER',
         year               => 'YEAR',
         second_microsecond => 'SECOND_MICROSECOND',
         minute_microsecond => 'MINUTE_MICROSECOND',
         minute_second      => 'MINUTE_SECOND',
         hour_microsecond   => 'HOUR_MICROSECOND',
         hour_second        => 'HOUR_SECOND',
         hour_minute        => 'HOUR_MINUTE',
         day_microsecond    => 'DAY_MICROSECOND',
         day_second         => 'DAY_SECOND',
         day_minute         => 'DAY_MINUTE',
         day_hour           => 'DAY_HOUR',
         year_month         => 'YEAR_MONTH',
      );

      my %diff_part_map = %part_map;
      $diff_part_map{day} = delete $diff_part_map{day_of_month};
      delete $diff_part_map{qw(
         second_microsecond minute_microsecond minute_second
         hour_microsecond hour_second hour_minute day_microsecond
         day_second day_minute day_hour year_month
      )};

      $d->decorate_driver_unconnected(mysql => datepart_sql => sub {
         sub {
            my ($date_sql, $part) = @_;

            my $sql = delete $date_sql->[0];

            return [
               "EXTRACT($part_map{$part} FROM $sql)", @$date_sql
            ]
         }
      });

      $d->decorate_driver_unconnected(mysql => dateadd_sql => sub {
         sub {
            my ($date_sql, $unit, $amount_sql) = @_;

            my ($d_sql, @d_args) = @{$date_sql};
            my ($a_sql, @a_args) = @{$amount_sql};

            die "unknown part $unit" unless $diff_part_map{$unit};

            return [
               "DATE_ADD($d_sql, INTERVAL $a_sql $diff_part_map{$unit})",
               @d_args, @a_args,
            ];
         }
      });
   }

   ORACLE: {
      my %part_map = (
         second       => 'SECOND',
         minute       => 'MINUTE',
         hour         => 'HOUR',
         day_of_month => 'DAY',
         month        => 'MONTH',
         year         => 'YEAR',
      );

      $d->decorate_driver_unconnected(Oracle => datepart_sql => sub {
         sub {
            my ($date_sql, $part) = @_;

            my $sql = delete $date_sql->[0];

            $sql = "TO_TIMESTAMP($sql)"
                if $part =~ /second|minute|hour/;
            return [
               "EXTRACT($part_map{$part} FROM $sql)", @$date_sql
            ]
         }
      });

      my %diff_part_map = %part_map;
      $diff_part_map{day} = delete $diff_part_map{day_of_month};
      delete $diff_part_map{$_} for qw(year month);
      $d->decorate_driver_unconnected(Oracle => dateadd_sql => sub {
         sub {
            my ($date_sql, $unit, $amount_sql) = @_;

            my ($d_sql, @d_args) = @{$date_sql};
            my ($a_sql, @a_args) = @{$amount_sql};

            die "unknown unit $unit" unless $diff_part_map{$unit};

            return [
               "($d_sql + NUMTODSINTERVAL($a_sql, ?))",
               @d_args, @a_args, $diff_part_map{$unit}
            ];
         }
      });
   }
   return $d;
}

use namespace::clean;

sub utc {
   my ($self, $datetime) = @_;

   my $tz_name = $datetime->time_zone->name;

   die "floating dates are not allowed"
      if $tz_name eq 'floating';

   $datetime = $datetime->clone->set_time_zone('UTC')
      unless $tz_name eq 'UTC';

   $_[0]->result_source->storage->datetime_parser->format_datetime($datetime)
}

sub dt_before {
   my ($self, $l, $r) = @_;

   my ($l_sql, @l_args) = _flatten_thing($self, $l);
   my ($r_sql, @r_args) = _flatten_thing($self, $r);

   return $self->search(\[
      "$l_sql < $r_sql", @l_args, @r_args
   ]);
}

sub dt_on_or_before {
   my ($self, $l, $r) = @_;

   my ($l_sql, @l_args) = _flatten_thing($self, $l);
   my ($r_sql, @r_args) = _flatten_thing($self, $r);

   $self->search(\[
      "$l_sql <= $r_sql", @l_args, @r_args
   ]);
}

sub dt_on_or_after {
   my ($self, $l, $r) = @_;

   my ($l_sql, @l_args) = _flatten_thing($self, $l);
   my ($r_sql, @r_args) = _flatten_thing($self, $r);

   return $self->search(\[
      "$l_sql >= $r_sql", @l_args, @r_args
   ]);
}

sub dt_after {
   my ($self, $l, $r) = @_;

   my ($l_sql, @l_args) = _flatten_thing($self, $l);
   my ($r_sql, @r_args) = _flatten_thing($self, $r);

   return $self->search(\[
      "$l_sql > $r_sql", @l_args, @r_args
   ]);
}

my $d;
sub utc_now {
   my $self = shift;
   my $storage = $self->result_source->storage;
   $storage->ensure_connected;

   $d ||= _introspector();

   return \( $d->get($storage->dbh, undef, 'now_utc_sql') );
}

sub dt_SQL_add {
   my ($self, $thing, $unit, $amount) = @_;

   my $storage = $self->result_source->storage;
   $storage->ensure_connected;

   $d ||= _introspector();

   return \(
      $d->get($storage->dbh, undef, 'dateadd_sql')->(
         [ _flatten_thing($self, $thing) ],
         $unit,
         [ _flatten_thing($self, $amount) ],
      )
   );
}

sub dt_SQL_pluck {
   my ($self, $thing, $part) = @_;

   my $storage = $self->result_source->storage;
   $storage->ensure_connected;

   $d ||= _introspector();

   return \(
      $d->get($storage->dbh, undef, 'datepart_sql')->(
         [ _flatten_thing($self, $thing) ],
         $part,
      )
   );
}

1;

=pod

=head1 SYNOPSIS

 package MySchema::ResultSet::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::ResultSet::DateMethods1');

 # in code using resultset

=for exec
perl maint/datemethods-sql-out mysql 1

=for exec
perl maint/datemethods-sql-out SQLite

=head1 DESCRIPTION

See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it
to your entire schema.

This ResultSet component gives the user tools to do B<mostly> portable date
manipulation in the database.  Before embarking on a cross database project,
take a look at L</IMPLEMENTATION> to see what might break on switching
databases.

This package has a few types of methods.

=over

=item Search Shortcuts

These, like typical ResultSet methods, return another ResultSet.  See
L</dt_before>, L</dt_on_or_before>, L</dt_on_or_after>, and L</dt_after>.

=item The date helper

There is only one: L</utc>.  Makes searching with dates a little easier.

=item SQL generators

These help generate more complex queries.  The can be used in many different
parts of L<DBIx::Class::ResultSet/search>.  See L</utc_now>, L</dt_SQL_pluck>,
and L</dt_SQL_add>.

=back

=method utc

 $rs->search({
   'some_date' => $rs->utc($datetime),
 })->all

Takes a L<DateTime> object, updates the C<time_zone> to C<UTC>, and formats it
according to whatever database engine you are using.

Dies if you pass it a date with a C<< floating time_zone >>.

=method utc_now

Returns a C<ScalarRef> representing the way to get the current date and time
in C<UTC> for whatever database engine you are using.

=method dt_before

 $rs->dt_before({ -ident => '.start' }, { -ident => '.end' })->all

Takes two values, each an expression of L</TYPES>.

=method dt_on_or_before

 $rs->dt_on_or_before({ -ident => '.start' }, DateTime->now)->all

Takes two values, each an expression of L</TYPES>.

=method dt_on_or_after

 $rs->dt_on_or_after(DateTime->now, { ident => '.end' })->all

Takes two values, each an expression of L</TYPES>.

=method dt_after

 $rs->dt_after({ ident => '.end' }, $rs->get_column('datecol')->as_query)->all

Takes two values, each an expression of L</TYPES>.

=method dt_SQL_add

 # which ones start in 3 minutes?
 $rs->dt_on_or_after(
    { ident => '.start' },
    $rs->dt_SQL_add($rs->utc_now, 'minute', 3)
 )->all

Takes three arguments: a date conforming to L</TYPES>, a unit, and an amount.
The idea is to add the given unit to the datetime.  See your L</IMPLEMENTATION>
for what units are accepted.

=method dt_SQL_pluck

 # get count per year
 $rs->search(undef, {
    columns => {
       count => '*',
       year  => $rs->dt_SQL_pluck({ -ident => '.start' }, 'year'),
    },
    group_by => [$rs->dt_SQL_pluck({ -ident => '.start' }, 'year')],
 })->hri->all

Takes two arguments: a date conforming to L</TYPES> and a unit.  The idea
is to pluck a given unit from the datetime.  See your L</IMPLEMENTATION>
for what units are accepted.

=head1 TYPES

Because these methods are so limited in scope they can be a bit more smart
than typical C<SQL::Abstract> trees.

There are "smart types" that this package supports.

=over

=item * vanilla scalars (C<1>, C<2012-12-12 12:12:12>)

bound directly as untyped values

=item * hashrefs with an C<-ident> (C<< { -ident => '.foo' } >>)

As usual this gets flattened into a column.  The one special feature in this
module is that columns starting with a dot will automatically be prefixed with
L<DBIx::Class::ResultSet/current_source_alias>.

=item * L<DateTime> objects

C<DateTime> objects work as if they were passed to L</utc>.

=item * C<ScalarRef> (C<< \'NOW()' >>)

As usual in C<DBIx::Class>, C<ScalarRef>'s will be flattened into regular SQL.

=item * C<ArrayRefRef> (C<< \["SELECT foo FROM bar WHERE id = ?", [{}, 1]] >>)

As usual in C<DBIx::Class>, C<ArrayRefRef>'s will be flattened into SQL with
bound values.

=back

Anything not mentioned in the above list will explode, one way or another.

=head1 IMPLEMENTATION

=encoding utf8

The exact details for the functions your database engine provides.

If a piece of functionality is flagged with ⚠, it means that the feature in
question is not portable at all, and only supported on that engine.

=head2 C<SQL Server>

=over

=item * L</utc_now> - L<GETUTCDATE|http://msdn.microsoft.com/en-us/library/ms178635.aspx>

=item * L</dt_SQL_pluck> - L<DATEPART|http://msdn.microsoft.com/en-us/library/ms174420.aspx>

Supported units

=over

=item * year

=item * quarter

=item * month

=item * day_of_year

=item * day_of_month

=item * week

=item * day_of_week

=item * hour

=item * minute

=item * second

=item * millisecond

=item * nanosecond ⚠

=item * non_iso_day_of_week

SQL Server offers both C<ISO_WEEK> and C<weekday>.  For interop reasons
C<weekday> uses the C<ISO_WEEK> version.

=item * timezone_as_minutes ⚠

=back

=item * L</dt_SQL_add> - L<DATEADD|http://msdn.microsoft.com/en-us/library/ms186819.aspx>

Supported units

=over

=item * year

=item * quarter

=item * month

=item * day

=item * week

=item * hour

=item * minute

=item * second

=item * millisecond

=item * nanosecond ⚠

=item * iso_day_of_week

=item * timezone_as_minutes ⚠

=back

=back

=head2 C<SQLite>

=over

=item * L</utc_now> - L<DATETIME('now')|https://www.sqlite.org/lang_datefunc.html>

=item * L</dt_SQL_pluck> - L<STRFTIME|https://www.sqlite.org/lang_datefunc.html>

Note: C<SQLite>'s pluck implementation pads numbers with zeros, because it is
implemented on based on a formatting function.  If you want your code to work
on SQLite you'll need to strip off (or just numify) what you get out of the
database first.

Available units

=over

=item * month

=item * day_of_month

=item * year

=item * hour

=item * day_of_year

=item * minute

=item * second

=item * day_of_week

=item * week

=item * julian_day ⚠

=item * seconds_since_epoch

=item * fractional_seconds ⚠

=back

=item * L</dt_SQL_add> - L<DATETIME|https://www.sqlite.org/lang_datefunc.html>

Available units

=over

=item * day

=item * hour

=item * minute

=item * second

=item * month

=item * year

=back

=back

=head2 C<PostgreSQL>

=over

=item * L</utc_now> - L<CURRENT_TIMESTAMP|http://www.postgresql.org/docs/current/static/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT>

=item * L</dt_SQL_pluck> - L<date_part|http://www.postgresql.org/docs/current/static/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT>

Available units

=over

=item * century ⚠

=item * decade ⚠

=item * day_of_month

=item * day_of_week

=item * day_of_year

=item * seconds_since_epoch

=item * hour

=item * iso_day_of_week

=item * iso_year

=item * microsecond

=item * millenium ⚠

=item * millisecond

=item * minute

=item * month

=item * quarter

=item * second

=item * timezone ⚠

=item * timezone_hour ⚠

=item * timezone_minute ⚠

=item * week

=item * year

=back

=item * L</dt_SQL_add> - Addition and L<interval|http://www.postgresql.org/docs/current/static/functions-datetime.html#OPERATORS-DATETIME-TABLE>

To be clear, it ends up looking like:
C<< ("some_column" + 5 * interval '1 minute') >>

Available units

=over

=item * century ⚠

=item * decade ⚠

=item * day

=item * hour

=item * microsecond ⚠

=item * millisecond

=item * minute

=item * month

=item * second

=item * week

=item * year

=back

=back

=head2 C<MySQL>

=over

=item * L</utc_now> - L<UTC_TIMESTAMP|https://dev.mysql.com/doc/refman/5.1/en/date-and-time-functions.html#function_utc-timestamp>

=item * L</dt_SQL_pluck> - L<EXTRACT|https://dev.mysql.com/doc/refman/5.1/en/date-and-time-functions.html#function_extract>

Available units

=over

=item * microsecond

=item * second

=item * minute

=item * hour

=item * day_of_month

=item * week

=item * month

=item * quarter

=item * year

=item * second_microsecond ⚠

=item * minute_microsecond ⚠

=item * minute_second ⚠

=item * hour_microsecond ⚠

=item * hour_second ⚠

=item * hour_minute ⚠

=item * day_microsecond ⚠

=item * day_second ⚠

=item * day_minute ⚠

=item * day_hour ⚠

=item * year_month ⚠

=back

=item * L</dt_SQL_add> - L<DATE_ADD|https://dev.mysql.com/doc/refman/5.1/en/date-and-time-functions.html#function_date-add>

Available units

=over

=item * microsecond

=item * second

=item * minute

=item * hour

=item * day

=item * week

=item * month

=item * quarter

=item * year

=back

=back

=head2 C<Oracle>

B<< ORACLE USERS BEWARE >>: I run all the tests on all of the databases
B<except> C<Oracle>.  If you have time to help make
L<dockerprove|https://github.com/frioux/DBIx-Class-Helpers/blob/master/dockerprove>
and/or L<travisci|https://github.com/frioux/DBIx-Class-Helpers/blob/master/.travis.yml>
test against C<Oracle> I'll gladly take those patches.  For hints look at
L<https://index.docker.io/u/wnameless/oracle-xe-11g/> and
L<https://github.com/dbsrgits/dbix-class/commit/003e97c53e065e7497a4946c29d5a94e7cf34389>.

=over

=item * L</utc_now> - L<sys_extract_utc(SYSTIMESTAMP)|http://docs.oracle.com/cd/B19306_01/server.102/b14200/functions167.htm>

=item * L</dt_SQL_pluck> - L<EXTRACT|docs.oracle.com/cd/B19306_01/server.102/b14200/functions050.htm>

Available units

=over

=item * second

=item * minute

=item * hour

=item * day_of_month

=item * month

=item * year

=back

=item * L</dt_SQL_add> - Addition and L<NUMTODSINTERVAL|http://docs.oracle.com/cd/B19306_01/server.102/b14200/functions103.htm>

To be clear, it ends up looking like:
C<< ("some_column" + NUMTODSINTERVAL(4, 'MINUTE') >>

Available units

=over

=item * second

=item * minute

=item * hour

=item * day

=back

=back

=head1 CONTRIBUTORS

These people worked on the original implementation, and thus deserve some
credit for at least providing me a reference to implement this based off of:

=over

=item Alexander Hartmaier (abraxxa) for Oracle implementation details

=item Devin Austin (dhoss) for Pg implementation details

=item Rafael Kitover (caelum) for providing a test environment with lots of DBs

=back

=head1 WHENCE dt_SQL_diff?

The original implementation of these date helpers (originally dubbed date
operators) included a third operator called C<"diff">.  It existed to
subtract one date from another and return a duration.  After using it a few
times and getting bitten every time, I decided to stop using it and instead
compare against actual dates always.  If someone can come up with a good use
case I am interested in re-implementing C<dt_SQL_diff>, but I worry that it
will be very unportable and generally not very useful.
