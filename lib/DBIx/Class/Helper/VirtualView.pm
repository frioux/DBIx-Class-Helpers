package DBIx::Class::Helper::VirtaulView;

use strict;
use warnings;

# ABSTRACT: Clean up your SQL namespace

sub as_virtual_view {
   my $self = shift;

   return $self->result_source->resultset->search( undef, {
      alias => 'me',
      from => [{ me => $self->as_query }]
   });
}

1;

=pod

=head1 SYNOPSIS

 # note that this is normally a component for a ResultSet
 package MySchema::ResultSet::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class::ResultSet';

 __PACKAGE__->load_components('Helper::VirtualView');

 # and then in code that uses the ResultSet Join with relation x
 my $rs = $schema->resultset('Bar')->search({'x.name' => 'abc'},{ join => 'x' });

 # 'x' now pollutes the query namespace

 # So the following works as expected
 my $ok_rs = $rs->search({'x.other' => 1});

 # But this doesn't: instead of finding a 'Bar' related to two x rows (abc and
 # def) we look for one row with contradictory terms and join in another table
 # (aliased 'x_2') which we never use
 my $broken_rs = $rs->search({'x.name' => 'def'});

 my $rs2 = $rs->as_virtual_view;

 # doesn't work - 'x' is no longer accessible in $rs2, having been sealed away
 my $not_joined_rs = $rs2->search({'x.other' => 1});

 # works as expected: finds a 'table' row related to two x rows (abc and def)
 my $correctly_joined_rs = $rs2->search({'x.name' => 'def'});

=head1 DESCRIPTION

This component is will allow you to clean up your SQL namespace.

=head1 METHODS

=head2 as_virtual_view

Act as a barrier to SQL symbols.  The resultset provided will be made into a
"virtual view" by including it as a subquery within the from clause.  From this
point on, any joined tables are inaccessible to ->search on the resultset (as if
it were simply where-filtered without joins).  See L</SYNOPSIS> for example.

=head1 NOTE

You don't I<have> to use this as a Component.  If you prefer you can use it
in the following manner:

 # in code using ResultSet:
 use DBIx::Class:Helper::VirtualView;

 my $new_rs = DBIx::Class::Helper::VirtualView::as_virtual_view($rs);
