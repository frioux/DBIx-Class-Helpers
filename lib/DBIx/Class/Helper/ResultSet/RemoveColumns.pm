package DBIx::Class::Helper::ResultSet::RemoveColumns;

use List::Util 'first';

# ABSTRACT: Remove columns from a ResultSet

sub new {
   my $class = shift;

   return $class->new_result(@_) if ref $class;

   my ($source, $attrs) = @_;

   if (
      exists $attrs->{remove_columns} &&
      !first { exists $attrs->{$_} }
         qw(columns cols select as _trailing_select)
   ) {
      my %rc = map { $_ => 1 } @{$attrs->{remove_columns}};
      $attrs->{columns} = [ grep { !$rc{$_} } $source->columns ]
   }

   return $class->next::method(@_);
}

1;

=pod

=head1 SYNOPSIS

 package MySchema::ResultSet::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::ResultSet::RemoveColumns');

 # in code using resultset:
 my $rs = $schema->resultset('Bar')->search(undef, {
    remove_columns => ['giant_text_col', 'password'],
 });

=head1 DESCRIPTION

This component allows convenient removal of columns from a select.
Normally to do this you would do this by listing all of the columns
B<except> the ones you want to remove.  This does that part for you.
See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to
your entire schema.

It doesn't get a lot more complicated than the synopsis.  If you are interested
in having more control, check out
L<DBIx::Class::Helper::ResultSet::AutoRemoveColumns>.

=over

=item *

Load the component

=item *

Put an C<ArrayRef> of columns to remove in the C<remove_columns> search attribute.

=item *

Profit.

=back
