package TestSchema::Result::Gnarly_Station;
use parent 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components(qw{Helper::JoinTable Core});

my $config = {
   left_class          => 'Gnarly',
   left_method         => 'gnarly',
   left_method_plural  => 'gnarlies',
   right_class         => 'Station',
   right_method        => 'station',
   right_method_plural => 'stations',
   self_method         => 'gnarly_stations',
};

__PACKAGE__->join_table($config);
__PACKAGE__->generate_has_manys($config);
__PACKAGE__->generate_many_to_manys($config);
__PACKAGE__->many_to_many( 'robots', 'foo_bar_baz', 'robot' );
1;
