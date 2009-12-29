package TestSchema::Result::Foo_Bar;
use parent 'DBIx::Class';
use strict;
use warnings;

 __PACKAGE__->load_components(qw{Helper::Row::JoinTable Core});

 __PACKAGE__->join_table({
    left_class   => 'Foo',
    right_class  => 'Bar',
    right_method => 'bar',
 });


1;
