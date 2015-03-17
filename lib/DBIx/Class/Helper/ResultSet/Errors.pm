package DBIx::Class::Helper::ResultSet::Errors;

# ABSTRACT: add exceptions to help when calling Result methods on an ResultSets

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

my $std_err = qq{Can't locate object method "%s" via package "%s" } .
              qq{at %s line %d.\n};

my $cust_err = qq{You're trying to call a Result ("%s") method ("%s") } .
               qq{on a ResultSet ("%s") at %s line %d.\n};

sub AUTOLOAD {
   my $self   = shift;

   my($class) = ref $self || $self;

   my($meth) = $DBIx::Class::Helper::ResultSet::Errors::AUTOLOAD
      =~ m/::([^:]+)$/;

   return if $meth eq 'DESTROY';

   my($callpack, $callfile, $callline) = caller;

   my $rclass = $self->result_source->result_class;

   die sprintf $cust_err, $rclass, $meth, $class, $callfile, $callline
      if $rclass->can($meth);

   die sprintf $std_err, $meth, $class, $callfile, $callline;
}

1;

__END__

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::ResultSet::Errors});

 ...

 1;

And then in a script or something:

 my $col = $rs->id

 # dies with a helpful error!

=head1 DESCRIPTION

Users new to C<DBIx::Class> often make the mistake of treating ResultSets like
Results.  This helper ameliorates the situation by giving a helpful error when
the user calls methods for the result on the ResultSet.  See
L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to your entire
schema.
