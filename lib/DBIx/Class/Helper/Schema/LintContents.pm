package DBIx::Class::Helper::Schema::LintContents;

# ABSTRACT: suite of methods to find violated "constraints"

use strict;
use warnings;

use parent 'DBIx::Class::Schema';

use Scalar::Util 'blessed';

sub null_check_source {
   my ($self, $source_name, $non_nullable_columns) = @_;

   return $self->resultset($source_name)->search({
      -or => [
         map +{ $_ => undef }, @$non_nullable_columns,
      ],
   })
}

sub null_check_source_auto {
   my ($self, $source_name) = @_;

   my %ci = %{
      $self->source($source_name)->columns_info
   };
   $self->null_check_source($source_name, [grep { !$ci{$_}->{is_nullable} } keys %ci]);
}

sub dup_check_source {
   my ($self, $source, $unique_columns) = @_;

   $self->resultset($source)->search(undef, {
      columns => $unique_columns,
      group_by => $unique_columns,
      having => \'count(*) > 1',
   })
}

sub dup_check_source_auto {
   my ($self, $source) = @_;

   my %uc = $self->source($source)->unique_constraints;
   return {
      map {
         $_ => scalar $self->dup_check_source($source, $uc{$_})
      } keys %uc
   }
}

sub _fk_cond_fixer {
   my ($self, $cond) = @_;

   return {
      map {
         my $k = $_;
         my $v = $cond->{$_};
         $_ =~ s/^(self|foreign)\.// for $k, $v;

         ($v => $k)
      } keys %$cond
   }
}

sub fk_check_source_auto {
   my ($self, $from_moniker) = @_;

   my $from_source = $self->source($from_moniker);
   my %rels = map {
      $_ => $from_source->relationship_info($_)
   } $from_source->relationships;

   return {
      map {
         $_ => scalar $self->fk_check_source(
            $from_moniker,
            $from_source->related_source($_),
            $self->_fk_cond_fixer($rels{$_}->{cond})
         )
      } grep {
         my %r = %{$rels{$_}};
         ref $r{cond} eq 'HASH' && ($r{attrs}{is_foreign_rel} || $r{attrs}{is_foreign_key_constraint})
      } keys %rels
   }
}

sub fk_check_source {
   my ($self, $source_from, $source_to, $columns) = @_;

   my $to_rs = blessed $source_to
      ? $source_to->resultset
      : $self->resultset($source_to)
   ;
   my $me = $self->resultset($source_from)->current_source_alias;
   $self->resultset($source_from)->search({
      -not_exists => $to_rs
         ->search({
            map +( "self.$_" => { -ident => "other.$columns->{$_}" } ), keys %$columns
         }, {
            alias => 'other',
         })->as_query,
   }, {
      alias => 'self',
   })
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema;

 use parent 'DBIx::Class::Schema';

 __PACKAGE__->load_components('Helper::Schema::LintContents');

 1;

And later, somewhere else:

 say "Incorrectly Null Users:";
 for ($schema->null_check_source_auto('User')->all) {
    say '* ' . $_->id
 }

 say "Duplicate Users:";
 my $duplicates = $schema->dup_check_source_auto('User');
 for (keys %$duplicates) {
    say "Constraint: $_";
    for ($duplicates->{$_}->all) {
       say '* ' . $_->id
    }
 }

 say "Users with invalid FK's:";
 my $invalid_fks = $schema->fk_check_source_auto('User');
 for (keys %$invalid_fks) {
    say "Rel: $_";
    for ($invalid_fks->{$_}->all) {
       say '* ' . $_->id
    }
 }

=head1 DESCRIPTION

Some people think that constraints make their databases slower.  As silly as
that is, I have been in a similar situation!  I'm here to help you, dear
developers!  Basically this is a suite of methods that allow you to find
violated "constraints."  To be clear, the constraints I mean are the ones you
tell L<DBIx::Class> about, real constraints are fairly sure to be followed.


=head1 METHODS

=head2 fk_check_source

 my $busted = $schema->fk_check_source(
   'User',
   'Group',
   { group_id => 'id' },
 );

C<fk_check_source> takes three arguments, the first is the B<from> source
moniker of a relationship.  The second is the B<to> source or source moniker of a relationship.
The final argument is a hash reference representing the columns of the
relationship.  The return value is a resultset of the B<from> source that do
not have a corresponding B<to> row.  To be clear, the example given above would
return a resultset of C<User> rows that have a C<group_id> that points to a
C<Group> that does not exist.

=head2 fk_check_source_auto

 my $broken = $schema->fk_check_source_auto('User');

C<fk_check_source_auto> takes a single argument: the source to check.  It will
check all the foreign key (that is, C<belongs_to>) relationships for missing...
C<foreign> rows.  The return value will be a hashref where the keys are the
relationship name and the values are resultsets of the respective violated
relationship.

=head2 dup_check_source

 my $smashed = $schema->fk_check_source( 'Group', ['id'] );

C<dup_check_source> takes two arguments, the first is the source moniker to be
checked.  The second is an arrayref of columns that "should be" unique.
The return value is a resultset of the source that duplicate the passed
columns.  So with the example above the resultset would return all groups that
are "duplicates" of other groups based on C<id>.

=head2 dup_check_source_auto

 my $ruined = $schema->dup_check_source_auto('Group');

C<dup_check_source_auto> takes a single argument, which is the name of the
resultsource in which to check for duplicates.  It will return a hashref where
they keys are the names of the unique constraints to be checked.  The values
will be resultsets of the respective duplicate rows.

=head2 null_check_source

 my $blarg = $schema->null_check_source('Group', ['id']);

C<null_check_source> tales two arguments, the first is the name of the source
to check.  The second is an arrayref of columns that should contain no nulls.
The return value is simply a resultset of rows that contain nulls where they
shouldn't be.

=head2 null_check_source_auto

 my $wrecked = $schema->null_check_source_auto('Group');

C<null_check_source_auto> takes a single argument, which is the name of the
resultsource in which to check for nulls.  The return value is simply a
resultset of rows that contain nulls where they shouldn't be.  This method
automatically uses the configured columns that have C<is_nullable> set to
false.

