package TestSchema::Result::ICDateTime;

use DBIx::Class::Candy -components => [
   'Helper::Row::ProxyResultSetMethod',
   'InflateColumn::DateTime',
];

table 'ICDateTime';

primary_column id => { data_type => 'int' };

column datetime => {
   data_type => 'datetime',
};

1;
