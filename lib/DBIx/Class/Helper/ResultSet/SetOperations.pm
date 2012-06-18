package DBIx::Class::Helper::ResultSet::SetOperations;

use strict;
use warnings;

# ABSTRACT: Do set operations with DBIx::Class

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
   shift->_set_operation( UNION => @_ );
}

sub union_all {
   shift->_set_operation( "UNION ALL" => @_ );
}

sub intersect {
   shift->_set_operation( INTERSECT => @_ );
}

sub intersect_all {
   shift->_set_operation( "INTERSECT ALL" => @_ );
}

sub _except_keyword {
   my $self = shift;

   $self->{_except_keyword} ||= ( $self->result_source->schema->storage->sqlt_type eq 'Oracle' ? "MINUS" : "EXCEPT" );
}

sub except {
   my ( $self, @args ) = @_;
   $self->_set_operation( $self->_except_keyword => @args );
}

sub except_all {
   # not supported on most DBs
   shift->_set_operation( "EXCEPT ALL" => @_ );
}

sub _set_operation {
   my ( $self, $operation, $other ) = @_;

   my @sql;
   my @params;

   my $as = $self->_resolved_attrs->{as};

   my @operands = ( $self, ref $other eq 'ARRAY' ? @$other : $other );

   for (@operands) {
      $self->throw_exception("ResultClass of ResultSets do not match!")
         unless $self->result_class eq $_->result_class;

      my $attrs = $_->_resolved_attrs;

      $self->throw_exception('ResultSets do not all have the same selected columns!')
         unless $self->_compare_arrays($as, $attrs->{as});

      my ($sql, $bind) = $self->result_source->storage->_select_args_to_query(
         $attrs->{from}, $attrs->{select}, $attrs->{where}, $attrs
      );

      push @sql, $sql;
      push @params, @{$bind};
   }

   my $query = q<(> . join(" $operation ", @sql). q<)>;

   my $attrs = $self->_resolved_attrs;
   return $self->result_source->resultset->search(undef, {
      alias => $self->current_source_alias,
      from => [{
         $self->current_source_alias => \[ $query, @params ],
         -alias                      => $self->current_source_alias,
         -source_handle              => $self->result_source->handle,
      }],
      columns => $attrs->{as},
      result_class => $self->result_class,
   });
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

 ...

 1;

And then elsewhere, like in a controller:

 my $rs1 = $rs->search({ foo => 'bar' });
 my $rs2 = $rs->search({ baz => 'biff' });
 for ($rs1->union($rs2)->all) { ... }

=head1 DESCRIPTION

This component allows you to use various set operations with your ResultSets.
See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to your
entire schema.

Component throws exceptions if ResultSets have different ResultClasses or
different "Columns Specs."

The basic idea here is that in SQL if you use a set operation they must be
selecting the same columns names, so that the results will all match.  The deal
with the ResultClasses is that DBIC needs to inflate the results the same for
the entire ResultSet, so if one were to try to apply something like a union in
a table with the same column name but different classes DBIC wouldn't be doing
what you would expect.

A nice way to use this is with L<DBIx::Class::ResultClass::HashRefInflator>.

You might have something like the following sketch autocompletion code:

 my $rs1 = $schema->resultset('Album')->search({
    name => { -like => "$input%" }
 }, {
   columns => [qw( id name ), {
      tablename => \['?', [{} => 'album']],
   }],
 });

 my $rs2 = $schema->resultset('Artist')->search({
    name => { -like => "$input%" }
 }, {
   columns => [qw( id name ), {
      tablename => \['?', [{} => 'artist']],
   }],
 });

 my $rs3 = $schema->resultset('Song')->search({
    name => { -like => "$input%" }
 }, {
   columns => [qw( id name ), {
      tablename => \['?', [{} => 'song']],
   }],
 });

 $_->result_class('DBIx::Class::ResultClass::HashRefInflator')
   for ($rs1, $rs2, $rs3);

 my $data = [$rs1->union([$rs2, $rs3])->all];

=head1 METHODS

=head2 union

=head2 union_all

=head2 intersect

=head2 intersect_all

=head2 except

=head2 except_all

All of these methods take a single ResultSet or an ArrayRef of ResultSets as
the parameter only parameter.

On Oracle C<except> will issue a C<MINUS> operation.

