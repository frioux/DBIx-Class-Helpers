package DBIx::Class::Helper::Schema::DateTime;

# ABSTRACT: DateTime helper

use strict;
use warnings;

sub datetime_parser { return shift->storage->datetime_parser }

sub parse_datetime { return shift->datetime_parser->parse_datetime(@_) }

sub format_datetime { return shift->datetime_parser->format_datetime(@_) }

1;

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::DateTime');

 ...

 $schema->resultset('Book')->search({
   written_on => $schema->format_datetime(DateTime->now)
 });
