package DBIx::Class::Helpers::Util;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [
      qw(
         get_namespace_parts assert_load_namespaces assert_not_load_namespaces
         assert_similar_namespaces
      ),
    ],
  };

sub get_namespace_parts {
   my $package = shift;

   if ($package =~ m/([\w:]+)::(\w+)/) {
      return ($1, $2);
   } else {
      die "$package doesn't look like".'$namespace::$resultclass';
   }
}

sub assert_load_namespaces {
   my $namespace = shift;
   $namespace =~ /^[\w:]+::Result::[\w]+$/;
}

sub assert_not_load_namespaces {
   my $namespace = shift;
      $namespace =~ /^([\w:]+)::[\w]+$/ and
      $1           !~ /::Result/;
}

sub assert_similar_namespaces {
   my $ns1 = shift;
   my $ns2 = shift;

   die "Namespaces $ns1 and $ns2 are dissimilar"
      unless assert_load_namespaces($ns1) and assert_load_namespaces($ns2) or
             assert_not_load_namespaces($ns1) and assert_not_load_namespaces($ns2);
}

1;

__END__

=pod

=head1 SYNOPSIS

 my ($namespace, $class) = get_namespace_parts('MyApp:Schema::Person');
 is $namespace, 'MyApp::Schema';
 is $class, 'Person';

=head1 DESCRIPTION

A collection of various helper utilities for L<DBIx::Class> stuff.  Probably
only useful for components.

=head1 METHODS

=head2 get_namespace_parts



=head2 assert_load_namespaces

=head2 assert_not_load_namespaces

=head2 assert_similar_namespaces

