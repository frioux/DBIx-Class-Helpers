requires 'DBIx::Class' => 0.08260;
requires 'Carp::Clan' => 6.04;
requires 'Sub::Exporter::Progressive' => 0.001006;
requires 'Lingua::EN::Inflect' => 0;
requires 'parent' => 0;
requires 'namespace::clean' => 0.23;
requires 'List::Util' => 0;
requires 'DBIx::Class::Candy' => 0.003001;
requires 'DBIx::Introspector' => 0.001002;
requires 'Module::Runtime';
requires 'Try::Tiny';
requires 'Safe::Isa';
requires 'Text::Brew';
requires 'Moo' => 2;
requires 'Hash::Merge';
requires 'Scalar::Util';
requires 'Types::SQL';

on test => sub {
   requires 'Test::More' => 0.94;
   requires 'Test::Deep' => 0;
   requires 'Test::Roo' => 1.003;
   requires 'DBD::SQLite' => 0;
   requires 'Test::Fatal' => 0.006;
   requires 'DateTime::Format::SQLite' => 0;
   requires 'aliased' => 0.34;
};
