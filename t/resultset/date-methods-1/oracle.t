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
      '("me"."a_date" + NUMTODSINTERVAL(?, ?))', 1, 'SECOND',
    ],

   add_sql_by_part => {
      day    => \[ '("a_date" + NUMTODSINTERVAL(?, ?))', 1, 'DAY' ],
      hour   => \[ '("a_date" + NUMTODSINTERVAL(?, ?))', 2, 'HOUR' ],
      minute => \[ '("a_date" + NUMTODSINTERVAL(?, ?))', 3, 'MINUTE' ],
      second => \[ '("a_date" + NUMTODSINTERVAL(?, ?))', 5, 'SECOND' ],
   },

   pluck_sql_prefix => \[ 'EXTRACT(SECOND FROM TO_TIMESTAMP("me"."a_date"))' ],

   pluck_sql_by_part => {
      second       => \[ 'EXTRACT(SECOND FROM TO_TIMESTAMP("a_date"))' ],
      minute       => \[ 'EXTRACT(MINUTE FROM TO_TIMESTAMP("a_date"))' ],
      hour         => \[ 'EXTRACT(HOUR FROM TO_TIMESTAMP("a_date"))' ],
      day_of_month => \[ 'EXTRACT(DAY FROM "a_date")' ],
      month        => \[ 'EXTRACT(MONTH FROM "a_date")' ],
      year         => \[ 'EXTRACT(YEAR FROM "a_date")' ],
   },
});

done_testing;
