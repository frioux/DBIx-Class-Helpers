package TestSchema::Result::Gnarly;

use DBIx::Class::Candy
   -components => ['Helper::Row::ToJSON'];

table 'Gnarly';

column 'id';
column 'name';

column literature => {
   data_type => 'text',
   is_nullable => 1,
};
column your_mom => {
   data_type => 'blob',
   is_nullable => 1,
   is_serializable => 1,
};

primary_key 'id';

1;
