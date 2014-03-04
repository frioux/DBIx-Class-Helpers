#!perl

use Test::Roo;
use Test::Deep;
use DateTime;
use Test::Fatal;

use lib 't/lib';
use TestSchema;

sub _dt {
   DateTime->new(
      time_zone => 'UTC',
      year => shift(@_), month => shift(@_), day => shift(@_),
   )
}

has on_connect_call => ( is => 'ro' );

has [qw(
   add_sql_by_part_skip add_sql_by_part_result
   pluck_sql_by_part_skip pluck_sql_by_part_result
)] => (
   is => 'ro',
   default => sub { {} },
);

has [map "${_}_sql_by_part", qw(pluck add)] => (
   is => 'ro',
   default => sub { {} },
);

sub skip_reason { 'set ' . join(q<, >, shift->env_vars) . ' to run these tests' }

sub env_vars {
   my $self = shift;

   my $p = 'DBIITEST_' . uc($self->engine);
   $p . '_DSN', $p . '_USER', $p . '_PASSWORD';
}

has connect_info => (
   is => 'ro',
   lazy => 1,
   default => sub {
      my $self = shift;
      my @connect_info = grep $_, map $ENV{$_}, $self->env_vars;
      push @connect_info, { on_connect_call => $self->on_connect_call }
         if @connect_info && $self->on_connect_call;

      return \@connect_info;
   },
);

has [qw(
   engine utc_now stringified_date add_sql_prefix
   sub_sql pluck_sql_prefix storage_type
)] => (is => 'ro');

has plucked_minute => (
   is => 'ro',
   default => 9,
);

has plucked_second => (
   is => 'ro',
   default => 8,
);

sub _merged_pluck_sql_by_part_result {
   my $self = shift;

   my %base = (
      year         => 2012,
      month        => 1,
      day_of_month => 2,
      hour         => 3,
      day_of_year  => 2,
      minute       => 4,
      second       => 5,
      day_of_week  => 1,
      week         => 1,
      quarter      => 1,
   );

   my %results = %{$self->pluck_sql_by_part_result};

   my @overrides = grep { $base{$_} } sort keys %results;
   note join(q(, ), @overrides) . ' overridden' if @overrides;

   return +{ %base, %results };
}

sub _merged_add_sql_by_part_result {
   my $self = shift;

   return +{
      day    => '2012-12-13 00:00:00',
      hour   => '2012-12-12 02:00:00',
      minute => '2012-12-12 00:03:00',
      month  => '2013-04-12 00:00:00',
      second => '2012-12-12 00:00:05',
      year   => '2018-12-12 00:00:00',
      %{$self->add_sql_by_part_result},
   }
}

sub connected { !!@{shift->connect_info} }

has schema => (
   is => 'ro',
   lazy => 1,
   builder => sub {
      my $self = shift;

      my $schema = 'TestSchema';
      $schema->storage_type('DBIx::Class::Storage::DBI'); # class methods: THE WORST
      $schema->storage_type('DBIx::Class::Storage::DBI::' . $self->storage_type)
         if $self->storage_type && !$self->connected;

      $schema = TestSchema->connect(@{$self->connect_info});
      $schema->deploy if $self->connected;
      $schema->storage->dbh->{private_dbii_driver} = $self->engine;

      $schema
   },
);

sub rs { shift->schema->resultset('HasDateOps') }

sub pop_rs_1 {
   my $self = shift;

   $self->rs->delete;
   $self->rs->populate([
      [qw(id a_date)],
      [1, $self->format_datetime(_dt(2012, 12, 12)), ],
      [2, $self->format_datetime(_dt(2012, 12, 13)), ],
      [3, $self->format_datetime(_dt(2012, 12, 14)), ],
   ])
}

sub pop_rs_2 {
   my $self = shift;

   my $dt1 = $self->format_datetime(_dt(2012, 12, 12));
   my $dt2 = $self->format_datetime(_dt(2012, 12, 13));
   $self->rs->delete;
   $self->rs->populate([
      [qw(id a_date b_date)],
      [1, $dt1, $dt2],
      [2, $dt1, $dt1],
      [3, $dt2, $dt1],
   ])
}

sub format_datetime {
   shift->schema
      ->storage
      ->datetime_parser
      ->format_datetime(shift @_)
}

sub parse_datetime {
   shift->schema
      ->storage
      ->datetime_parser
      ->parse_datetime(shift @_)
}

test basic => sub {
   my $self = shift;

   is(${$self->rs->utc_now}, $self->utc_now, 'utc_now');

   like(exception {
      $self->rs->utc(DateTime->new(year => 1985, month => 1, day => 1))
   }, qr/floating dates are not allowed/, 'no floating dates');

   SKIP: {
      skip $self->skip_reason, 1 unless $self->connected;

      my $central_date = DateTime->new(
         year   => 2014,
         month  => 2,
         day    => 7,
         hour   => 22,
         minute => 43,
         time_zone => 'America/Chicago',
      );

      is(
         $self->rs->utc($central_date),
         $self->stringified_date,
         'datetime correctly UTC and stringified'
      );

      my $local_dt = DateTime->now( time_zone => 'UTC' );

      $self->rs->delete;
      $self->rs->create({ id => 1, a_date => $self->rs->utc_now });

      my $remote_dt = $self->parse_datetime($self->rs->next->a_date);

      ok(
         $local_dt->subtract_datetime_absolute($remote_dt)->seconds < 60,
         'UTC works! (and clock is correct)',
      );
   }
};

sub _comparisons {
   my ($self, $l, $r, $n) = @_;
   subtest $n => sub {
      cmp_deeply(
         [$self->rs->dt_before($l => $r)->get_column('id')->all],
         [1],
         'before',
      );

      cmp_deeply(
         [$self->rs->dt_on_or_before($l, $r)->get_column('id')->all],
         bag(1, 2),
         'on_or_before',
      );

      cmp_deeply(
         [$self->rs->dt_on_or_after($l, $r)->get_column('id')->all],
         bag(2, 3),
         'on_or_after',
      );

      cmp_deeply(
         [$self->rs->dt_after($l, $r)->get_column('id')->all],
         [3],
         'after',
      );
   };
}

sub _middle_comparisons {
   my ($self, $r) = @_;

   $self->_comparisons({ -ident => 'a_date' } => $r, 'no prefix');

   $self->_comparisons({ -ident => '.a_date' } => $r, 'auto prefix');

   $self->_comparisons(
      { -ident => $self->rs->current_source_alias . '.a_date' }
         => $r, 'manual prefix'
   )
}

test comparisons => sub {
   my $self = shift;

   SKIP: {
      skip $self->skip_reason, 1 unless $self->connected;

      $self->pop_rs_1;

      my $dt = _dt(2012, 12, 13);
      subtest 'datetime object' =>
         sub { $self->_middle_comparisons($dt) };

      subtest 'datetime literal'=> sub {
         $self->_middle_comparisons($self->format_datetime($dt))
      };

      subtest subquery => sub {
         $self->_middle_comparisons(
            $self->rs->search({ id => 2})->get_column('a_date')->as_query
         )
      };

      subtest 'both columns' => sub {
         $self->pop_rs_2;

         $self->_middle_comparisons({ -ident => '.b_date' }, 'auto prefix');
         $self->_middle_comparisons({ -ident => 'b_date' }, 'no prefix');
         $self->_middle_comparisons(
            { -ident => $self->rs->current_source_alias . '.b_date' },
            'manual prefix',
         );
      };

      subtest 'literal SQL' => sub {
         cmp_deeply(
            [$self->rs->dt_before(
               { -ident => '.b_date' },
               $self->rs->utc_now
            )->get_column('id')->all],
            [1, 2, 3],
            'literal SQL compared (and db clock correct)',
         );
      };
   }
};

test add => sub {
   my $self = shift;

   $self->pop_rs_1 if $self->connected;

   SKIP: {
      skip $self->engine  . q(doesn't set add_sql_prefix) unless $self->add_sql_prefix;

      my %offset = (
         day => 1,
         hour => 2,
         minute => 3,
         month => 4,
         second => 5,
         year => 6,
      );
      my $i = 1 + scalar keys %offset;
      for my $part (sort keys %{$self->add_sql_by_part}) {
         my $query = $self->rs->dt_SQL_add(
            { -ident => 'a_date' },
            $part,
            $offset{$part} || $i++,
         );
         SKIP: {
            skip $self->skip_reason, 1 unless $self->connected;
            skip $self->add_sql_by_part_skip->{$part}, 1
               if $self->add_sql_by_part_skip->{$part};

            my $v;
            my $e = exception {
               $v = $self->rs->search({ id => 1 }, {
                  columns => { v => $query },
               })->get_column('v')->next;
            };
            ok !$e, "live $part" or diag "exception: $e";
            is($v, $self->_merged_add_sql_by_part_result->{$part}, "suspected $part");
         }

         cmp_deeply(
            $query,
            $self->add_sql_by_part->{$part},
            "unit: $part",
         );
      }

      cmp_deeply(
         $self->rs->dt_SQL_add({ -ident => '.a_date' }, 'second', 1),
         $self->add_sql_prefix,
         'vanilla add',
      );
   }

   SKIP: {
      skip $self->skip_reason, 1 unless $self->connected;

      my $dt = DateTime->new(
         time_zone => 'UTC',
         year => 2013,
         month => 12,
         day => 11,
         hour => 10,
         minute => 9,
         second => 8,
      );

      $self->rs->delete;
      $self->rs->create({ id => 1, a_date => $self->rs->utc($dt) });

      my $added = $self->rs->search(undef, {
         rows => 1,
         columns => { foo =>
            $self->rs->dt_SQL_add(
               $self->rs->dt_SQL_add(
                  $self->rs->dt_SQL_add({ -ident => '.a_date' }, 'minute', 2),
                     second => 4,
               ), hour => 1,
            ),
         },
         result_class => 'DBIx::Class::ResultClass::HashRefInflator',
      })->first->{foo};
      $added = $self->parse_datetime($added);

      is($added->year => 2013, 'added year');
      is($added->month => 12, 'added month');
      is($added->day => 11, 'added day');
      is($added->hour => 11, 'added hour');
      is($added->minute => 11, 'added minute');
      is($added->second => 12, 'added second');
   }
};

test pluck => sub {
   my $self = shift;

   if ($self->connected) {
      $self->rs->delete;
      $self->rs->populate([
         [qw(id a_date)],
         [1, $self->format_datetime(
               DateTime->new(
                  year => 2012,
                  month => 1,
                  day => 2,
                  hour => 3,
                  minute => 4,
                  second => 5,
               )
            )
         ],
      ])
   }

   my $i = 1;
   for my $part (sort keys %{$self->pluck_sql_by_part}) {
         SKIP: {
            skip $self->skip_reason, 1 unless $self->connected;
            skip $self->pluck_sql_by_part_skip->{$part}, 1
               if $self->pluck_sql_by_part_skip->{$part};

            my $res;
            my $e = exception {
               $res = $self->rs->search({ id => 1 }, {
                  columns => {
                     a_date => 'a_date',
                     v => $self->rs->dt_SQL_pluck({ -ident => 'a_date' }, $part)
                  },
                  result_class => 'DBIx::Class::ResultClass::HashRefInflator',
               })->next;
            };
            my $v = $res->{v};
            my $date = $res->{a_date};
            ok !$e, "live $part" or diag "exception: $e";
            is(
               $v,
               $self->_merged_pluck_sql_by_part_result->{$part},
               "suspected $part"
            ) or diag "for date $date";
         }

      cmp_deeply(
         $self->rs->dt_SQL_pluck({ -ident => 'a_date' }, $part),
         $self->pluck_sql_by_part->{$part},
         "unit $part",
      );
   }

   cmp_deeply(
      $self->rs->dt_SQL_pluck({ -ident => '.a_date' }, 'second'),
      $self->pluck_sql_prefix,
      'vanilla pluck',
   );

   SKIP: {
      skip $self->skip_reason, 1 unless $self->connected;

      my $dt = DateTime->new(
         time_zone => 'UTC',
         year => 2013,
         month => 12,
         day => 11,
         hour => 10,
         minute => 9,
         second => 8,
      );

      $self->rs->delete;
      $self->rs->create({ id => 1, a_date => $self->rs->utc($dt) });

      my @parts = qw(year month day_of_month hour minute second);
      my $plucked = $self->rs->search(undef, {
         rows => 1,
         select => [map $self->rs->dt_SQL_pluck({ -ident => '.a_date' }, $_), @parts],
         as => \@parts,
         result_class => 'DBIx::Class::ResultClass::HashRefInflator',
      })->first;

      cmp_deeply($plucked, {
         year => 2013,
         month => 12,
         day_of_month => 11,
         hour => 10,
         minute => $self->plucked_minute,
         second => $self->plucked_second,
      }, 'live pluck works');
   }
};

run_me(SQLite => {
   engine => 'SQLite',
   utc_now => q<DATETIME('now')>,
   stringified_date => '2014-02-08 04:43:00',

   plucked_minute => '09',
   plucked_second => '08',

   connect_info => [ 'dbi:SQLite::memory:' ],


   add_sql_prefix => \[ 'DATETIME("me"."a_date", ? || ?)', 1, ' seconds' ],

   add_sql_by_part => {
      day    => \[ 'DATETIME("a_date", ? || ?)', 1, ' days' ],
      hour   => \[ 'DATETIME("a_date", ? || ?)', 2, ' hours' ],
      minute => \[ 'DATETIME("a_date", ? || ?)', 3, ' minutes' ],
      month  => \[ 'DATETIME("a_date", ? || ?)', 4, ' months' ],
      second => \[ 'DATETIME("a_date", ? || ?)', 5, ' seconds' ],
      year   => \[ 'DATETIME("a_date", ? || ?)', 6, ' years' ],
   },

   pluck_sql_prefix => \[ q<STRFTIME('%S', "me"."a_date")> ],

   pluck_sql_by_part => {
      year                => \[ q<STRFTIME('%Y', "a_date")> ],
      month               => \[ q<STRFTIME('%m', "a_date")> ],
      day_of_month        => \[ q<STRFTIME('%d', "a_date")> ],
      hour                => \[ q<STRFTIME('%H', "a_date")> ],
      day_of_year         => \[ q<STRFTIME('%j', "a_date")> ],
      minute              => \[ q<STRFTIME('%M', "a_date")> ],
      second              => \[ q<STRFTIME('%S', "a_date")> ],
      day_of_week         => \[ q<STRFTIME('%w', "a_date")> ],
      week                => \[ q<STRFTIME('%W', "a_date")> ],
      julian_day          => \[ q<STRFTIME('%J', "a_date")> ],
      seconds_since_epoch => \[ q<STRFTIME('%s', "a_date")> ],
      fractional_seconds  => \[ q<STRFTIME('%f', "a_date")> ],
   },

   pluck_sql_by_part_result => {
      month               => '01',
      day_of_month        => '02',
      hour                => '03',
      day_of_year         => '002',
      minute              => '04',
      second              => '05',
      week                => '01',
      julian_day          => '2455928.627835648',
      seconds_since_epoch => '1325473445',
      fractional_seconds  => '05.000',
   },

});

run_me(MSSQL => {
   engine => 'MSSQL',
   utc_now => 'GETUTCDATE()',
   stringified_date => '2014-02-08 04:43:00.000',


   storage_type => 'MSSQL',

   add_sql_prefix => \[ 'DATEADD(second, CAST(? AS int), [me].[a_date])', 1  ],

   add_sql_by_part_skip => {
      nanosecond => "doesn't work with DATETIME data type",
   },

   add_sql_by_part => {
      day         => \[ 'DATEADD(dayofyear, CAST(? AS int), [a_date])',   1  ],
      hour        => \[ 'DATEADD(hour, CAST(? AS int), [a_date])',        2  ],
      millisecond => \[ 'DATEADD(millisecond, CAST(? AS int), [a_date])', 7  ],
      minute      => \[ 'DATEADD(minute, CAST(? AS int), [a_date])',      3  ],
      month       => \[ 'DATEADD(month, CAST(? AS int), [a_date])',       4  ],
      nanosecond  => \[ 'DATEADD(nanosecond, CAST(? AS int), [a_date])',  8  ],
      quarter     => \[ 'DATEADD(quarter, CAST(? AS int), [a_date])',     9  ],
      second      => \[ 'DATEADD(second, CAST(? AS int), [a_date])',      5  ],
      week        => \[ 'DATEADD(week, CAST(? AS int), [a_date])',        10 ],
      year        => \[ 'DATEADD(year, CAST(? AS int), [a_date])',        6  ],
   },

   add_sql_by_part_result => {
      day         => '2012-12-13 00:00:00.000',
      hour        => '2012-12-12 02:00:00.000',
      millisecond => '2012-12-12 00:00:00.007',
      minute      => '2012-12-12 00:03:00.000',
      month       => '2013-04-12 00:00:00.000',
      quarter     => '2015-03-12 00:00:00.000',
      second      => '2012-12-12 00:00:05.000',
      week        => '2013-02-20 00:00:00.000',
      year        => '2018-12-12 00:00:00.000',
   },

   pluck_sql_prefix => \[ q<DATEPART(second, [me].[a_date])> ],

   pluck_sql_by_part => {
      year                => \[ 'DATEPART(year, [a_date])' ],
      quarter             => \[ 'DATEPART(quarter, [a_date])' ],
      month               => \[ 'DATEPART(month, [a_date])' ],
      day_of_year         => \[ 'DATEPART(dayofyear, [a_date])' ],
      day_of_month        => \[ 'DATEPART(day, [a_date])' ],
      week                => \[ 'DATEPART(week, [a_date])' ],
      day_of_week         => \[ 'DATEPART(ISO_WEEK, [a_date])' ],
      hour                => \[ 'DATEPART(hour, [a_date])' ],
      minute              => \[ 'DATEPART(minute, [a_date])' ],
      second              => \[ 'DATEPART(second, [a_date])' ],
      millisecond         => \[ 'DATEPART(millisecond, [a_date])' ],
      nanosecond          => \[ 'DATEPART(nanosecond, [a_date])' ],
      non_iso_day_of_week => \[ 'DATEPART(weekday, [a_date])' ],
      timezone_as_minutes => \[ 'DATEPART(TZoffset, [a_date])' ],
   },

   pluck_sql_by_part_skip => {
      timezone_as_minutes => 'not supported by DateTime data type',
   },

   pluck_sql_by_part_result => {
      millisecond         => 0,
      nanosecond          => 0,
      non_iso_day_of_week => 2,
   },

});

run_me(Pg => {
   engine => 'Pg',
   utc_now => 'CURRENT_TIMESTAMP',
   stringified_date => '2014-02-08 04:43:00+0000',

   storage_type => 'Pg',

   add_sql_prefix => \[ q<("me"."a_date" + ? * interval '1 second')>, 1],

   add_sql_by_part => {
      century     => \[ q<("a_date" + ? * interval '1 century')>,      7  ],
      day         => \[ q<("a_date" + ? * interval '1 day')>,          1  ],
      decade      => \[ q<("a_date" + ? * interval '1 decade')>,       8  ],
      hour        => \[ q<("a_date" + ? * interval '1 hour')>,         2  ],
      microsecond => \[ q<("a_date" + ? * interval '1 microseconds')>, 9 ],
      millisecond => \[ q<("a_date" + ? * interval '1 milliseconds')>, 10 ],
      minute      => \[ q<("a_date" + ? * interval '1 minute')>,       3  ],
      month       => \[ q<("a_date" + ? * interval '1 month')>,        4  ],
      second      => \[ q<("a_date" + ? * interval '1 second')>,       5  ],
      week        => \[ q<("a_date" + ? * interval '1 week')>,         11 ],
      year        => \[ q<("a_date" + ? * interval '1 year')>,         6  ],
   },

   add_sql_by_part_result => {
      century     => '2712-12-12 00:00:00',
      decade      => '2092-12-12 00:00:00',
      microsecond => '2012-12-12 00:00:00.000009',
      millisecond => '2012-12-12 00:00:00.01',
      week        => '2013-02-27 00:00:00',
   },

   pluck_sql_prefix => \[ 'date_part(?, "me"."a_date")', 'second' ],

   pluck_sql_by_part => {
      century             => \[ 'date_part(?, "a_date")', 'century' ],
      decade              => \[ 'date_part(?, "a_date")', 'decade' ],
      day_of_month        => \[ 'date_part(?, "a_date")', 'day' ],
      day_of_week         => \[ 'date_part(?, "a_date")', 'dow' ],
      day_of_year         => \[ 'date_part(?, "a_date")', 'doy' ],
      seconds_since_epoch => \[ 'date_part(?, "a_date")', 'epoch' ],
      hour                => \[ 'date_part(?, "a_date")', 'hour' ],
      iso_day_of_week     => \[ 'date_part(?, "a_date")', 'isodow' ],
      iso_year            => \[ 'date_part(?, "a_date")', 'isoyear' ],
      microsecond         => \[ 'date_part(?, "a_date")', 'microseconds' ],
      millenium           => \[ 'date_part(?, "a_date")', 'millenium' ],
      millisecond         => \[ 'date_part(?, "a_date")', 'milliseconds' ],
      minute              => \[ 'date_part(?, "a_date")', 'minute' ],
      month               => \[ 'date_part(?, "a_date")', 'month' ],
      quarter             => \[ 'date_part(?, "a_date")', 'quarter' ],
      second              => \[ 'date_part(?, "a_date")', 'second' ],
      timezone            => \[ 'date_part(?, "a_date")', 'timezone' ],
      timezone_hour       => \[ 'date_part(?, "a_date")', 'timezone_hour' ],
      timezone_minute     => \[ 'date_part(?, "a_date")', 'timezone_minute' ],
      week                => \[ 'date_part(?, "a_date")', 'week' ],
      year                => \[ 'date_part(?, "a_date")', 'year' ],
   },

   pluck_sql_by_part_skip => {
      millenium => 'not supported by DateTime data type',
      timezone => 'not supported by DateTime data type',
      timezone_hour => 'not supported by DateTime data type',
      timezone_minute => 'not supported by DateTime data type',
   },

   pluck_sql_by_part_result => {
      century             => 21,
      decade              => 201,
      seconds_since_epoch => '1325473445',
      iso_day_of_week     => 1,
      iso_year            => 2012,
      microsecond         => '5000000',
      millisecond         => 5000,
   },

});

run_me(mysql => {
   engine => 'mysql',
   utc_now => 'UTC_TIMESTAMP()',
   stringified_date => '2014-02-08 04:43:00',

   storage_type => 'mysql',

   pluck_sql_prefix => \[ 'EXTRACT(SECOND FROM `me`.`a_date`)' ],

   pluck_sql_by_part => {
      microsecond        => \[ 'EXTRACT(MICROSECOND FROM `a_date`)' ],
      second             => \[ 'EXTRACT(SECOND FROM `a_date`)' ],
      minute             => \[ 'EXTRACT(MINUTE FROM `a_date`)' ],
      hour               => \[ 'EXTRACT(HOUR FROM `a_date`)' ],
      day_of_month       => \[ 'EXTRACT(DAY FROM `a_date`)' ],
      week               => \[ 'EXTRACT(WEEK FROM `a_date`)' ],
      month              => \[ 'EXTRACT(MONTH FROM `a_date`)' ],
      quarter            => \[ 'EXTRACT(QUARTER FROM `a_date`)' ],
      year               => \[ 'EXTRACT(YEAR FROM `a_date`)' ],
      second_microsecond => \[ 'EXTRACT(SECOND_MICROSECOND FROM `a_date`)' ],
      minute_microsecond => \[ 'EXTRACT(MINUTE_MICROSECOND FROM `a_date`)' ],
      minute_second      => \[ 'EXTRACT(MINUTE_SECOND FROM `a_date`)' ],
      hour_microsecond   => \[ 'EXTRACT(HOUR_MICROSECOND FROM `a_date`)' ],
      hour_second        => \[ 'EXTRACT(HOUR_SECOND FROM `a_date`)' ],
      hour_minute        => \[ 'EXTRACT(HOUR_MINUTE FROM `a_date`)' ],
      day_microsecond    => \[ 'EXTRACT(DAY_MICROSECOND FROM `a_date`)' ],
      day_second         => \[ 'EXTRACT(DAY_SECOND FROM `a_date`)' ],
      day_minute         => \[ 'EXTRACT(DAY_MINUTE FROM `a_date`)' ],
      day_hour           => \[ 'EXTRACT(DAY_HOUR FROM `a_date`)' ],
      year_month         => \[ 'EXTRACT(YEAR_MONTH FROM `a_date`)' ],
   },

   pluck_sql_by_part_result => {
      microsecond        => 0,
      second_microsecond => '5000000',
      minute_microsecond => '405000000',
      minute_second      => 405,
      hour_microsecond   => '30405000000',
      hour_second        => 30405,
      hour_minute        => 304,
      day_microsecond    => '2030405000000',
      day_second         => '2030405',
      day_minute         => 20304,
      day_hour           => 203,
      year_month         => '201201',
   },

   add_sql_prefix => \[ 'DATE_ADD(`me`.`a_date`, INTERVAL ? SECOND)', 1 ],

   add_sql_by_part => {
      day         => \[ 'DATE_ADD(`a_date`, INTERVAL ? DAY)',         1 ],
      hour        => \[ 'DATE_ADD(`a_date`, INTERVAL ? HOUR)',        2 ],
      microsecond => \[ 'DATE_ADD(`a_date`, INTERVAL ? MICROSECOND)', 7 ],
      minute      => \[ 'DATE_ADD(`a_date`, INTERVAL ? MINUTE)',      3 ],
      month       => \[ 'DATE_ADD(`a_date`, INTERVAL ? MONTH)',       4 ],
      quarter     => \[ 'DATE_ADD(`a_date`, INTERVAL ? QUARTER)',     8 ],
      second      => \[ 'DATE_ADD(`a_date`, INTERVAL ? SECOND)',      5 ],
      week        => \[ 'DATE_ADD(`a_date`, INTERVAL ? WEEK)',        9 ],
      year        => \[ 'DATE_ADD(`a_date`, INTERVAL ? YEAR)',        6 ],
   },

   add_sql_by_part_result => {
      microsecond => '2012-12-12 00:00:00.000007',
      quarter     => '2014-12-12 00:00:00',
      week        => '2013-02-13 00:00:00',
   },

});

local $SIG{__WARN__} = sub {
   my $warning = shift;

   return if $warning =~
      m/DBIx::Class::Storage::DBI::Oracle.*sql_(?:limit_dialect|quote_char)/;

   print STDERR $warning;
};

run_me(Oracle => {
   on_connect_call => 'datetime_setup',

   engine => 'Oracle',
   utc_now => 'sys_extract_utc(SYSTIMESTAMP)',

   storage_type => 'Oracle',

   add_sql_prefix => \[
      '("me"."a_date" + NUMTODSINTERVAL(?, ?)', 1, 'SECOND',
    ],

   add_sql_by_part => {
      day    => \[ '("a_date" + NUMTODSINTERVAL(?, ?)', 1, 'DAY' ],
      hour   => \[ '("a_date" + NUMTODSINTERVAL(?, ?)', 2, 'HOUR' ],
      minute => \[ '("a_date" + NUMTODSINTERVAL(?, ?)', 3, 'MINUTE' ],
      second => \[ '("a_date" + NUMTODSINTERVAL(?, ?)', 5, 'SECOND' ],
   },

   pluck_sql_prefix => \[ 'EXTRACT(SECOND FROM "me"."a_date")' ],

   pluck_sql_by_part => {
      second       => \[ 'EXTRACT(SECOND FROM "a_date")' ],
      minute       => \[ 'EXTRACT(MINUTE FROM "a_date")' ],
      hour         => \[ 'EXTRACT(HOUR FROM "a_date")' ],
      day_of_month => \[ 'EXTRACT(DAY FROM "a_date")' ],
      month        => \[ 'EXTRACT(MONTH FROM "a_date")' ],
      year         => \[ 'EXTRACT(YEAR FROM "a_date")' ],
   },

});

done_testing;

