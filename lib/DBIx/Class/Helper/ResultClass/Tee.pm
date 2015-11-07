package DBIx::Class::Helper::ResultClass::Tee;

use Moo 2;
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

   die "..." unless blessed($self);

   [ map scalar use_module($_)->inflate_result(@rest), @{$self->inner_classes} ]
}

1;
