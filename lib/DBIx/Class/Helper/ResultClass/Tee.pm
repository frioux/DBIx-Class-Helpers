package DBIx::Class::Helper::ResultClass::Tee;

# ABSTRACT: Inflate to multiple result classes at the same time

use utf8;

use Moo;
use Module::Runtime 'use_module';
use Scalar::Util 'blessed';

has inner_classes => (
   is => 'ro',
   required => 1,
   coerce => sub {
      [ map {
         s/^::/DBIx::Class::ResultClass::/;
         s/::HRI$/::HashRefInflator/;
         $_
      } @{$_[0]} ]
   },
);

sub inflate_result {
   my ($self, @rest) = @_;

   [ map scalar use_module($_)->inflate_result(@rest), @{$self->inner_classes} ]
}

1;

__END__

=pod

=head1 SYNOPSIS

   my ($hashref, $obj) = $rs->search(undef, {
      result_class => DBIx::Class::Helper::ResultClass::Tee->new(
         inner_classes => [ '::HRI', 'MyApp::Schema::Result::User'],
      ),
   })->first->@*;

(If you've never seen C<< ->@* >> before, check out
L<perlref/Postfix-Dereference-Syntax>, added in Perl v5.20!)

=head1 DESCRIPTION

This result class has one obvious use case: when you have prefetched data and
L<DBIx::Class::ResultClass::HashRefInflator> is the simplest way to access all
the data, but you still want to use some of the methods on your existing result
class.

=encoding UTF-8

The other important I<raison d'être> of this module is that it is an example of
how to make a "parameterized" result class.  It's almost a secret that
L<DBIx::Class> supports using objects to inflate results.  This is an incredibly
powerful feature that can be used to make consistent interfaces to do all kinds
of things.

Once when I was at Micro Technology Services, Inc. I used it to efficiently do a
"reverse synthetic, LIKE-ish join".  The "relationship" was basically
C<< foreign.name =~ self.name >>, which cannot actually be done if you want to
go from within the database, but if you are able to load the entire foreign
table into memory this can be done on-demand, and cached within the result class
for (in our case) the duration of a request.
