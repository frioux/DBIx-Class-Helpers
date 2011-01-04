package DBIx::Class::Helper::ResultSet::ResultClassDWIM;

# ABSTRACT: result_class => '::HRI' == WIN

use strict;
use warnings;

sub _calculate_result_class {
   my ($self, $r_c) = @_;

   if (defined $r_c && !ref $r_c) {
      if ($r_c eq '::HRI') {
         return 'DBIx::Class::ResultClass::HashRefInflator'
      } elsif ($r_c =~ /^::/) {
         return "DBIx::Class::ResultClass$r_c"
      }
   }
}

sub search {
   my ($self, $query, $meta) = @_;

   return $self->next::method($query) unless defined $meta;

   if (my $r_c = $self->_calculate_result_class($meta->{result_class})) {
      $meta->{result_class} = $r_c
   }

   $self->next::method($query, $meta);
}

sub result_class {
   my ($self, $result_class) = @_;

   return $self->next::method unless defined $result_class;

   if (my $r_c = $self->_calculate_result_class($result_class)) {
      $result_class = $r_c
   }

   $self->next::method($result_class);
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::ResultSet::ResultClassDWIM});

 ...

 1;

And then elsewhere:

 my $data = $schema->resultset('Foo')->search({
      name => 'frew'
   }, {
      result_class => '::HRI'
   })->all;

=head1 DESCRIPTION

This component allows you to prefix your C<result_class> with C<::> to indicate
that it should use the default namespace, namely, C<DBIx::Class::ResultClass::>.

C<::HRI> has been hardcoded to work.  Of course C<::HashRefInflator> would
also work fine.

See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to your
entire schema.

