package TestSchema::Result::Gnarly_Station;

use DBIx::Class::Candy
   -components => ['Helper::Row::JoinTable'];

my $config = {
   left_class          => 'Gnarly',
   left_method         => 'gnarly',
   left_method_plural  => 'gnarlies',
   right_class         => 'Station',
   right_method        => 'station',
   right_method_plural => 'stations',
   self_method         => 'gnarly_stations',
};

join_table $config;
generate_has_manys $config;
generate_many_to_manys $config;

1;
