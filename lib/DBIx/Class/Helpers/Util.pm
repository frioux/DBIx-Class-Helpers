package DBIx::Class::Helpers::Util;

use strict;
use warnings;

# ABSTRACT: Helper utilities for DBIx::Class components

use Sub::Exporter::Progressive -setup => {
    exports => [
      qw(
         get_namespace_parts is_load_namespaces is_not_load_namespaces
         assert_similar_namespaces
      ),
    ],
  };

sub get_namespace_parts {
   my $package = shift;

   if ($package =~ m/(^[\w:]+::Result)::([\w:]+)$/) {
      return ($1, $2);
   } else {
      die "$package doesn't look like ".'$namespace::Result::$resultclass';
   }
}

sub is_load_namespaces {
   my $namespace = shift;
   $namespace =~ /^[\w:]+::Result::[\w:]+$/;
}

sub is_not_load_namespaces {
   my $namespace = shift;
      $namespace =~ /^([\w:]+)::[\w]+$/ and
      $1           !~ /::Result/;
}

sub assert_similar_namespaces {
   my $ns1 = shift;
   my $ns2 = shift;

   die "Namespaces $ns1 and $ns2 are dissimilar"
      unless is_load_namespaces($ns1) and is_load_namespaces($ns2) or
             is_not_load_namespaces($ns1) and is_not_load_namespaces($ns2);
}

1;

__END__

=pod

=head1 SYNOPSIS

 my ($namespace, $class) = get_namespace_parts('MyApp:Schema::Person');
 is $namespace, 'MyApp::Schema';
 is $class, 'Person';

 if (is_load_namespaces('MyApp::Schema::Result::Person')) {
   print 'correctly structured project';
 }

 if (is_not_load_namespaces('MyApp::Schema::Person')) {
   print 'incorrectly structured project';
 }

 if (assert_similar_namespaces('MyApp::Schema::Person', 'FooApp::Schema::People')) {
   print 'both projects are structured similarly';
 }

 if (assert_similar_namespaces('MyApp::Schema::Result::Person', 'FooApp::Schema::Result::People')) {
   print 'both projects are structured similarly';
 }

=head1 DESCRIPTION

A collection of various helper utilities for L<DBIx::Class> stuff.  Probably
only useful for components.

=head1 METHODS

=head2 get_namespace_parts

Returns the namespace and class name of a package.  See L</SYNOPSIS> for example.

=head2 is_load_namespaces

Returns true if a package is structured in a way that would work for
load_namespaces.  See L</SYNOPSIS> for example.

=head2 is_not_load_namespaces

Returns true if a package is structured in a way that would not work for
load_namespaces.  See L</SYNOPSIS> for example.

=head2 assert_similar_namespaces

Dies if both packages are structured in the same way.  The same means both are
load_namespaces or both are not.  See L</SYNOPSIS> for example.

