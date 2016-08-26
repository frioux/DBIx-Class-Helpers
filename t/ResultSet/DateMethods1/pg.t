#!perl

use strict;
use warnings;
use Test::More;
use lib 't/lib';
use DBIx::RetryConnect 'Pg';
use A::ResultSet::DateMethods1;

A::ResultSet::DateMethods1->run_tests(Pg => {
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

done_testing;
