package TestSchema;
use parent 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
   default_resultset_class => 'ResultSet',
);

'kitten eater';
