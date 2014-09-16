#!perl

use strict;
use warnings;
use Test::More;
use lib 't/lib';
use A::ResultSet::DateMethods1;

local $SIG{__WARN__} = sub {
   my $warning = shift;

   return if $warning =~
      m/DBIx::Class::Storage::DBI::Oracle.*sql_(?:limit_dialect|quote_char)/;

   print STDERR $warning;
};

A::ResultSet::DateMethods1->run_tests(Oracle => {
   on_connect_call => 'datetime_setup',

   engine => 'Oracle',
   utc_now => 'sys_extract_utc(SYSTIMESTAMP)',
   stringified_date => '2014-02-08 04:43:00',

   storage_type => 'Oracle',

   add_sql_prefix => \[
      '(TO_TIMESTAMP("me"."a_date") + NUMTODSINTERVAL(?, ?))', 1, 'SECOND',
    ],

   add_sql_by_part => {
      day    => \[ '(TO_TIMESTAMP("a_date") + NUMTODSINTERVAL(?, ?))', 1, 'DAY' ],
      hour   => \[ '(TO_TIMESTAMP("a_date") + NUMTODSINTERVAL(?, ?))', 2, 'HOUR' ],
      minute => \[ '(TO_TIMESTAMP("a_date") + NUMTODSINTERVAL(?, ?))', 3, 'MINUTE' ],
      second => \[ '(TO_TIMESTAMP("a_date") + NUMTODSINTERVAL(?, ?))', 5, 'SECOND' ],
   },

   add_sql_by_part_result => {
      day         => '2012-12-13 00:00:00.000000000',
      hour        => '2012-12-12 02:00:00.000000000',
      millisecond => '2012-12-12 00:00:00.007000000',
      minute      => '2012-12-12 00:03:00.000000000',
      month       => '2013-04-12 00:00:00.000000000',
      quarter     => '2015-03-12 00:00:00.000000000',
      second      => '2012-12-12 00:00:05.000000000',
      week        => '2013-02-20 00:00:00.000000000',
      year        => '2018-12-12 00:00:00.000000000',
   },

   pluck_sql_prefix => \[ 'EXTRACT(SECOND FROM TO_TIMESTAMP("me"."a_date"))' ],

   pluck_sql_by_part => {
      second       => \[ 'EXTRACT(SECOND FROM TO_TIMESTAMP("a_date"))' ],
      minute       => \[ 'EXTRACT(MINUTE FROM TO_TIMESTAMP("a_date"))' ],
      hour         => \[ 'EXTRACT(HOUR FROM TO_TIMESTAMP("a_date"))' ],
      day_of_month => \[ 'EXTRACT(DAY FROM TO_TIMESTAMP("a_date"))' ],
      month        => \[ 'EXTRACT(MONTH FROM TO_TIMESTAMP("a_date"))' ],
      year         => \[ 'EXTRACT(YEAR FROM TO_TIMESTAMP("a_date"))' ],
   },
});

done_testing;
