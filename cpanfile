requires 'DBIx::Class' => 0.08127;
requires 'Carp::Clan' => 6.04;
requires 'Sub::Exporter::Progressive' => 0.001006;
requires 'Lingua::EN::Inflect' => 0;
requires 'parent' => 0;
requires 'String::CamelCase' => 0;
requires 'namespace::clean' => 0.23;
requires 'List::Util' => 0;
requires 'DBIx::Class::Candy' => 0.001003;

on test => sub {
   requires 'Test::More' => 0.94;
   requires 'Test::Deep' => 0;
   requires 'DBD::SQLite' => 0;
   requires 'Test::Exception' => 0;
   requires 'Test::Roo' => 0;
};
