package TestSchema::ResultSet::Foo;
use strict;
use warnings;

use parent 'TestSchema::ResultSet';

__PACKAGE__->load_components(qw{
   Helper::ResultSet::Bare
   Helper::ResultSet::RemoveColumns
   Helper::ResultSet::Union
   Helper::ResultSet::Random
   Helper::ResultSet::ResultClassDWIM
   Helper::ResultSet::Shortcut
});

1;
