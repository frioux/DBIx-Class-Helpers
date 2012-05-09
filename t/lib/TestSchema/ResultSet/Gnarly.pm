package TestSchema::ResultSet::Gnarly;
use strict;
use warnings;

use parent 'TestSchema::ResultSet';

__PACKAGE__->load_components(qw{ Helper::ResultSet::ResultClassDWIM Helper::ResultSet::CorrelateRelationship });

1;
