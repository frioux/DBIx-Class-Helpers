package DBIx::Class::Helper::ResultSet::SearchOr;

# ABSTRACT: Combine ResultSet searches with OR's

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

use List::Util 'first';
use Carp::Clan;
use namespace::clean;

sub search_or {
   my $self = shift;
   my @others = @{shift @_ };

   croak 'All ResultSets passed to search_or must have the same result_source ' .
         'as the invocant!' if first { $self->result_source != $_->result_source } @others;

   $self->search({
      -or => [
         map $_->_resolved_attrs->{where}, @others
      ],
   });
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Tests;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components(qw(Helper::ResultSet::IgnoreWantarray Helper::ResultSet::SearchOr));

 sub failed {
   my $self = shift;

   my $me = $self->current_source_alias;

   $self->search({ "$me.passed" => '0' });
 }

 sub untested {
   my $self = shift;

   my $me = $self->current_source_alias;

   $self->search({ "$me.passed" => undef });
 }

 sub not_passed {
   my $self = shift;

   my $me = $self->current_source_alias;

   $self->search_or([$self->failed, $self->untested]);
 }

 1;

=head1 DESCRIPTION

I would argue that the most important feature of L<DBIx::Class> is the fact
that you can "chain" ResultSet searches.  Unfortunately this can cause problems
when you need to reuse multiple ResultSet methods as... well as or's.  In the
past I got around this by doing:

 $rs->foo->union([ $rs->bar]);

While this works, it can generate some hairy SQL pretty fast.  This Helper is
supposed to basically be a lightweight union.  Note that it therefor has a
number of L</LIMITATIONS>.  The thing that makes this module special is that
the ResultSet that is doing the "search_or" ing still limits everything
correctly.  To be clear, the following only returns C<$user>'s friends that
match either of the following criteria:

 my $friend_rs = $schema->resultset('Friend');
 my @internet_friends = $user->friends->search_or([
   $friend_rs->on_facebook,
   $friend_rs->on_twitter,
 ])->all;

With a union, you'd have to implement it like this:

 $user->friends->on_facebook->union([ $user->friends->on_twitter ]);

The union will work, but it will generate more complex SQL that may have lower
performance on your database.

See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to
your entire schema.

=head1 METHODS

=head2 search_or

 my $new_rs = $rs->search_or([ $rs->foo, $rs->bar ]);

C<search_or> takes a single arrayref of ResultSets.  The ResultSets B<must>
point to the same source or you will get an error message.  Additionally, no
check is made to ensure that more than one ResultSet is in the ArrayRef, but
only passing one ResultSet would not make any sense.

=head1 LIMITATIONS

Because this module us basically an expression union and not a true union,
C<JOIN>'s won't Just Work.  If you have a ResultSet method that uses a C<JOIN>
and you want to C<OR> it with another method, you'll need to do something like
this:

 my @authors = $authors->search(undef, { join => 'books' })->search_or([
    $authors->wrote_good_books,
    $authors->wrote_bestselling_books,
 ])->all;

Furthermore, if you want to C<OR> two methods that C<JOIN> in the same
relationship via alternate paths you B<must> use
L<union|DBIx::Class::Helper::ResultSet::SetOperations/union>.
