package A::ResultSet::DateMethods1;

use Test::Roo;
use Test::Deep 'cmp_deeply', 'bag';
use DateTime;
use Test::Fatal;

with 'A::Role::TestConnect';

use lib 't/lib';

sub _dt {
   DateTime->new(
      time_zone => 'UTC',
      year => shift(@_), month => shift(@_), day => shift(@_),
   )
}

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

has _skip_msg_once => ( is => 'rw' );
sub skip_reason {
   return '(see above)' if $_[0]->_skip_msg_once;
   $_[0]->_skip_msg_once(1);
   'set ' . join(q<, >, shift->env_vars) . ' to run these tests'
}

has [qw(
   utc_now stringified_date add_sql_prefix sub_sql pluck_sql_prefix
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
            my $expected = $self->_merged_add_sql_by_part_result->{$part};

            if (ref $expected && ref $expected eq 'Regexp') {
               like($v, $expected, "suspected $part");
            } else {
               is($v, $expected, "suspected $part");
            }
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

      subtest column => sub {
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
      };

      subtest bindarg => sub {
         my $added = $self->rs->search(undef, {
            rows => 1,
            columns => { foo =>
               $self->rs->dt_SQL_add(
                  $self->rs->dt_SQL_add(
                     $self->rs->dt_SQL_add($dt, 'minute', 2),
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
      };
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
      {
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
         }, 'live pluck works from column');
      }
      {
         my $plucked = $self->rs->search(undef, {
            rows => 1,
            select => [map $self->rs->dt_SQL_pluck($dt, $_), @parts],
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
         }, 'live pluck works from bindarg');
   }
   }
};

1;
