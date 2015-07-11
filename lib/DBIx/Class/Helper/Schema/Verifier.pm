package DBIx::Class::Helper::Schema::Verifier;

# ABSTRACT: Verify the Results and ResultSets of your Schemata

use strict;
use warnings;

use MRO::Compat;
use mro 'c3';

use Try::Tiny;
use namespace::clean;

use base 'DBIx::Class::Schema';

sub result_verifiers {
   return ()
}

our $_FATAL = 1;
our @_ERRORS;

sub register_source {
   my ($self, $name, $rclass) = @_;

   unless ($_FATAL) {
      $self->$_($rclass->result_class, $rclass->resultset_class)
         for $self->result_verifiers;
   } else {
      for ($self->result_verifiers) {
         try {
            $self->$_($rclass->result_class, $rclass->resultset_class)
         } catch {
            push @_ERRORS, $_
         }
      }
   }

   $self->next::method($name, $rclass);
}

sub load_namespaces {
   local $_FATAL = 1;

   shift->next::method(@_);

   my @e = @_ERRORS;
   @_ERRORS = ();
   die sort @e if @e;
}

sub load_classes {
   local $_FATAL = 1;

   shift->next::method(@_);

   my @e = @_ERRORS;
   @_ERRORS = ();
   die sort @e if @e;
}

1;

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::Verifier');

 sub result_verifiers {
   (
      sub {
         my ($self, $result, $set) = @_;

         for ($result, $set) {
            die "$_ does not start with the letter A" unless m/^A/
         }
      },
      shift->next::method,
   )
 }

=head1 DESCRIPTION

C<DBIx::Class::Helper::Schema::Verifier> is a miniscule framework to assist in
creating schemata that are to your very own exacting specifications.  It is
inspired by my own travails in discovering that C<< use mro 'c3' >> is both
required and barely documented in much Perl code.  As time goes by I expect to
add many more verifiers, but with this inaugural release I am merely including
L<DBIx::Class::Helper::Schema::Verifier::C3>.

=head1 INTERFACE METHODS

=head2 result_verifiers

You must implement C<result_verifiers> in your subclass of C<::Verifier>.  Each
verifier gets called on the schema and gets each result and resultset together
as arguments.  You can use this to validate almost anything about the results
and resultsets of a schema; contributions are warmly welcomed.

=head1 MORE ERRORS

Initially I kept this module simple, but after using it in production at
L<ZipRecruiter|https://www.ziprecruiter.com> I found that showing the user the
first error that occured and then giving up was pretty annoying.  Now
C<Schema::Verifier> wraps both L<DBIx::Class::Schema/load_namespaces> and
L<DBIx::Class::Schema/load_classes> and shows all the exceptions encoutered as a
list at the end of loading all the results.
