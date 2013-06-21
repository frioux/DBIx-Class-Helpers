package DBIx::Class::Helper::Schema::GenerateSource;

# ABSTRACT: Generate sources directly from your Schema

use strict;
use warnings;

# VERSION

use Scalar::Util 'blessed';

sub _schema_class { blessed($_[0]) || $_[0] }

sub _generate_class_name {
   $_[0]->_schema_class . '::GeneratedResult::__' . uc $_[1]
}

sub _generate_class {
   die $@ unless eval "
   package $_[1]; use parent '$_[2]'; __PACKAGE__->table(__PACKAGE__->table); 1;
   ";
}

sub generate_source {
   my ($self, $moniker, $base) = @_;

   my $class = $self->_generate_class_name($moniker);
   $self->_generate_class($class, $base);
   $self->register_class($moniker, $class);
}

1;

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::GenerateSource');

 __PACKAGE__->generate_source(User => 'MyCompany::BaseResult::User');

=head1 DESCRIPTION

This helper allows you to handily and correctly add new result sources to your
schema based on existing result sources.  Typically this would be done with
something like:

 package MyApp::Schema::Result::MessegeQueue;

 use parent 'MyCo::Schema::Result::MessageQueue';

 __PACKAGE__->table(__PACKAGE__->table);

 1;

which clearly is in its own file.  This should still be done when you need to
add columns or really do B<anything> other than just basic addition of the
result source to your schema.

B<Note>: This component correctly generates an "anonymous" subclass of the given
base class.  Do not depend on the name of the subclass as it is currently
considered unstable.

=head1 METHODS

=head2 generate_source

 $schema->generate_source(User => 'MyCompany::BaseResult::User')

The first argument to C<generate_source> is the C<moniker> to register the
class as, the second argument is the base class for the new result source.
