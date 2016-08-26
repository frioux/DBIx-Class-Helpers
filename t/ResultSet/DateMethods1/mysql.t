#!perl

use strict;
use warnings;
use Test::More;
use lib 't/lib';
use DBIx::RetryConnect 'mysql';
use A::ResultSet::DateMethods1;

A::ResultSet::DateMethods1->run_tests(mysql => {
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

done_testing;
