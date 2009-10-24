package DBIx::Class::Helpers::Util;
use strict;
use warnings;

use feature ':5.10';

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
   my $namespace_1 = shift;
   my $namespace_2 = shift;
   $namespace_1 =~ /^[\w:]+::Result::[\w]+$/ and
   $namespace_2 =~ /^[\w:]+::Result::[\w]+$/;
}

sub assert_not_load_namespaces {
   my $namespace_1 = shift;
   my $namespace_2 = shift;
      $namespace_1 =~ /^([\w:]+)::[\w]+$/ and
      $1           !~ /::Result/        and
      $namespace_2 =~ /^([\w:]+)::[\w]+$/ and
      $1           !~ /::Result/;
}

sub assert_similar_namespaces {
   my $ns1 = shift;
   my $ns2 = shift;

   die "Namespaces $ns1 and $ns2 are dissimilar"
      unless assert_load_namespaces($ns1, $ns2) or
             assert_not_load_namespaces($ns1, $ns2);
}

1;

__END__

=pod

