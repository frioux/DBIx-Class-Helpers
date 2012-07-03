package DBIx::Class::Helper::ResultSet::CorrelateRelationship;

use strict;
use warnings;

# ABSTRACT: Easily correlate your ResultSets

sub correlate {
   my ($self, $rel) = @_;

   my $source = $self->result_source;
   my $rel_info = $source->relationship_info($rel);

   return $source->related_source($rel)->resultset
      ->search(scalar $source->_resolve_condition(
         $rel_info->{cond},
         "${rel}_alias",
         $self->current_source_alias,
         $rel
      ), {
         alias => "${rel}_alias",
      })
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Author;

 use base 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components(qw(Helper::ResultSet::CorrelateRelationship));

 sub with_book_count {
   my $self = shift;

   $self->search(undef, {
     '+columns' => {
       book_count => $self->correlate('book')->count_rs->as_query
     }
   });
 }

 1;

And then elsewhere, like in a controller:

 my $rows = $schema->resultset('Author')->with_book_count->all;

=head1 DESCRIPTION

Correlated queries are one of the coolest things I've learned about for SQL
since my initial learning of SQL.  Unfortunately they are somewhat confusing.
L<DBIx::Class> has supported doing them for a long time, but generally people
don't think of them because they are so rare.  I won't go through all the
details of how they work and cool things you can do with them, but here are a
couple high level things you can use them for to save you time or effort.

If you want to select a list of authors and counts of books for each author,
you B<could> use C<group_by> and something like C<COUNT(book.id)>, but then
you'd need to make your select list match your C<group_by> and it would just
be a hassle forever after that.  The L</SYNOPSIS> is a perfect example of how
to implement this.

If you want to select a list of authors and two separate kinds of counts of
books for each author, as far as I know, you B<must> use a correlated subquery
in L<DBIx::Class>.  Here is an example of how you might do that:

 package MyApp::Schema::ResultSet::Author;

 use base 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components(qw(Helper::ResultSet::CorrelateRelationship));

 sub with_good_book_count {
   my $self = shift;

   $self->search(undef, {
     '+columns' => {
       good_book_count => $self->correlate('books')->good->count_rs->as_query
     }
   });
 }

 sub with_bad_book_count {
   my $self = shift;

   $self->search(undef, {
     '+columns' => {
       bad_book_count => $self->correlate('books')->bad->count_rs->as_query
     }
   });
 }

 1;

And then elsewhere, like in a controller:

 my $rows = $schema->resultset('Author')
   ->with_bad_book_count
   ->with_good_book_count
   ->all;

This assumes that the Book resultset has C<good> and C<bad> methods.

See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to
your entire schema.

=head1 METHODS

=head2 correlate

 $rs->correlate($relationship_name)

Correlate takes a single argument, a relationship for the invocant, and returns
a resultset that can be used in the selector list.
