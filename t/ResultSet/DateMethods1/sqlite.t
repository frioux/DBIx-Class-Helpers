#!perl

use strict;
use warnings;
use Test::More;
use lib 't/lib';
use A::ResultSet::DateMethods1;

A::ResultSet::DateMethods1->run_tests(SQLite => {
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

   subtract_sql_prefix => \[ q{DATETIME("me"."a_date", '-' || ? || ?)}, 1, ' seconds' ],

   subtract_sql_by_part => {
      day    => \[ q{DATETIME("a_date", '-' || ? || ?)}, 1, ' days' ],
      hour   => \[ q{DATETIME("a_date", '-' || ? || ?)}, 2, ' hours' ],
      minute => \[ q{DATETIME("a_date", '-' || ? || ?)}, 3, ' minutes' ],
      month  => \[ q{DATETIME("a_date", '-' || ? || ?)}, 4, ' months' ],
      second => \[ q{DATETIME("a_date", '-' || ? || ?)}, 5, ' seconds' ],
      year   => \[ q{DATETIME("a_date", '-' || ? || ?)}, 6, ' years' ],
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

done_testing;
