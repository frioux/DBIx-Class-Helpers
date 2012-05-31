package TestSchema::Result::Gnarly;

use DBIx::Class::Candy
   -components => [qw(
      Helper::Row::ToJSON
      Helper::Row::ProxyResultSetMethod
   )];

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

proxy_resultset_method 'id_plus_one';

proxy_resultset_method id_plus_two => {
   resultset_method => 'id_plus_two',
   slot             => 'plus2',
};

1;
