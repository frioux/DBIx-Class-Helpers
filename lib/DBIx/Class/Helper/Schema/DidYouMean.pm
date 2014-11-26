package DBIx::Class::Helper::Schema::DidYouMean;

# ABSTRACT: Nice error messages when you misspell the name of a ResultSet

use strict;
use warnings;

use Text::Brew 'distance';
use Try::Tiny;
use namespace::clean;

sub source {
   my ($self, @rest) = @_;

   my $method = $self->next::can;

   try {
      $self->$method(@rest)
   } catch {
      if (m/Can't find source for (.+?) at/) {
         my @presentsources = map {
           (distance($_, $1))[0] < 3 ? " * $_ <-- Possible Match\n" : "   $_\n";
         } sort $self->storage->schema->sources;

         die <<"ERR";
$_
The ResultSet "$1" is not part of your schema.

To help you debug this issue, here's a list of the actual sources that the
schema knows about:

 @presentsources
ERR
      }
      die $_;
   }
}

1;

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::DidYouMean');

Elsewhere:

 $schema->resultset('Usre')->search(...)->...

And a nice exception gets thrown:

 The ResultSet "Usre" is not part of your schema.
 
 To help you debug this issue, here's a list of the actual sources that the
 schema knows about:
 
     Account
     Permission
     Role
   * User <-- Possible Match

=head1 DESCRIPTION

This helper captures errors thrown when you use the C<resultset> method on your
schema and typo the source name.  It tries to highlight the best guess as to
which you meant to type.
