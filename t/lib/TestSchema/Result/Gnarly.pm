package TestSchema::Result::Gnarly;

use DBIx::Class::Candy
   -components => [qw(
      Helper::Row::ToJSON
      Helper::Row::ProxyResultSetMethod
      Helper::Row::OnColumnMissing
   )];

table 'Gnarly';

primary_column id => { data_type => 'int' };
column name => { data_type => 'varchar' };

column literature => {
   data_type => 'text',
   is_nullable => 1,
};
column your_mom => {
   data_type => 'blob',
   is_nullable => 1,
   is_serializable => 1,
};

proxy_resultset_method 'id_plus_one';

proxy_resultset_method id_plus_two => {
   resultset_method => 'id_plus_two',
   slot             => 'plus2',
};

our $MISSING = 'warn';
sub on_column_missing { $MISSING }

1;
