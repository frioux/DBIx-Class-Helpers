#!perl

use strict;
use warnings;
use Test::More;
use lib 't/lib';
use A::ResultSet::DateMethods1;

A::ResultSet::DateMethods1->run_tests(MSSQL => {
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

done_testing;
