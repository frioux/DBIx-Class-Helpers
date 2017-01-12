package TestSchema::Result::SerializeAll;

use DBIx::Class::Candy
   -components => [qw(
      Helper::Row::ToJSON
   )];

table 'SerializeAll';

primary_column id => { data_type => 'int' };;
column text_column => { data_type => 'text' };

sub unserializable_data_types { {} }

1;
