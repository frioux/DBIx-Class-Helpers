package DBIx::Class::Helper::ResultSet::Union;

use strict;
use warnings;

# ABSTRACT: Do unions with DBIx::Class

# cribbed from perlfaq4
sub _compare_arrays {
   my ($self, $first, $second) = @_;

   no warnings; # silence spurious -w undef complaints
   return 0 unless @$first == @$second;
   for (my $i = 0; $i < @$first; $i++) {
      return 0 if $first->[$i] ne $second->[$i];
   }
   return 1;
}

sub union {
   my ( $self, $other) = @_;

   $other = [$other] if ref $other ne 'ARRAY';

   push @{$other}, $self;

   my @sql;
   my @params;

   my $as = $self->_resolved_attrs->{as};

   for (@{$other}) {
      $self->throw_exception('ResultClass of queries passed to union do not match!')
         unless ref $self->_result_class eq ref $_->_result_class;

      my $attrs = $_->_resolved_attrs;

      $self->throw_exception('ResultSets do not all have the same selected columns!')
         unless $self->_compare_arrays($as, $attrs->{as});

      my ($sql, $bind) = $self->result_source->storage->_select_args_to_query(
         $attrs->{from}, $attrs->{select}, $attrs->{where}, $attrs
      );

      push @sql, $sql;
      push @params, @{$bind};
   }

   my $query = q<(> . join(' UNION ', @sql). q<)>;

   return $self->result_source->resultset->search(undef, {
      from => [{
         me             => \[ $query, @params ],
         -alias         => $self->current_source_alias,
         -source_handle => $self->result_source->handle,
      }]
   });
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::ResultSet::Union});

 ...

 1;

And then elsewhere, like in a controller:

 my $rs1 = $rs->search({ foo => 'bar' });
 my $rs2 = $rs->search({ baz => 'biff' });
 for ($rs1->union($rs2)->all) { ... }

=head1 DESCRIPTION

This component allows you to create unions with your ResultSets.

=head1 METHODS

=head2 union

Takes a single ResultSet or an ArrayRef of ResultSets as the parameter.

Component throws exceptions if ResultSets have different ResultClasses or
different "Columns Specs."

=head2 NOTE

You probably want this applied to your entire schema.  The most convenient
way to do that is to make a base ResultSet and inherit from that in all of
your custom ResultSets as well has make it the default ResultSet for the
non-custom ResultSets.  Example:

 package My::App::Schema::ResultSet;

 use strict;
 use warnings;

 use base 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::IgnoreWantarray');

 1;

 package My::App::Schema;

 use base 'DBIx::Class::Schema';

 My::App::Schema->load_namespaces(
    default_resultset_class => 'ResultSet',
 );

 1;

