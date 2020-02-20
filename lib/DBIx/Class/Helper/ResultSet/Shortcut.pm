package DBIx::Class::Helper::ResultSet::Shortcut;

# ABSTRACT: Shortcuts to common searches (->order_by, etc)

use strict;
use warnings;

use parent (qw(
   DBIx::Class::Helper::ResultSet::Shortcut::AddColumns
   DBIx::Class::Helper::ResultSet::Shortcut::Columns
   DBIx::Class::Helper::ResultSet::Shortcut::Distinct
   DBIx::Class::Helper::ResultSet::Shortcut::GroupBy
   DBIx::Class::Helper::ResultSet::Shortcut::HasRows
   DBIx::Class::Helper::ResultSet::Shortcut::HRI
   DBIx::Class::Helper::ResultSet::Shortcut::Limit
   DBIx::Class::Helper::ResultSet::Shortcut::OrderByMagic
   DBIx::Class::Helper::ResultSet::Shortcut::Prefetch
   DBIx::Class::Helper::ResultSet::Shortcut::LimitedPage
   DBIx::Class::Helper::ResultSet::Shortcut::RemoveColumns
   DBIx::Class::Helper::ResultSet::Shortcut::ResultsExist
   DBIx::Class::Helper::ResultSet::Shortcut::Rows
   DBIx::Class::Helper::ResultSet::Shortcut::Page
   DBIx::Class::Helper::ResultSet::Shortcut::Search
));

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::ResultSet::Shortcut});

 ...

 1;

And then elsewhere:

 # let's say you grab a resultset from somewhere else
 my $foo_rs = get_common_rs()
 # but I'd like it sorted!
   ->order_by({ -desc => 'power_level' })
 # and without those other dumb columns
   ->columns([qw/cromulence_ratio has_jimmies_rustled/])
 # but get rid of those duplicates
   ->distinct
 # and put those straight into hashrefs, please
   ->hri
 # but only give me the first 3
   ->rows(3);

=head1 DESCRIPTION

This helper provides convenience methods for resultset modifications.

See L<DBIx::Class::Helper::ResultSet/NOTE> for a nice way to apply it to your
entire schema.

=method distinct

 $foo_rs->distinct

 # equivalent to...
 $foo_rs->search(undef, { distinct => 1 });

=method group_by

 $foo_rs->group_by([ qw/ some column names /])

 # equivalent to...
 $foo_rs->search(undef, { group_by => [ qw/ some column names /] });

=method order_by

 $foo_rs->order_by({ -desc => 'col1' });

 # equivalent to...
 $foo_rs->search(undef, { order_by => { -desc => 'col1' } });

You can also specify the order as a "magic string", e.g.:

 $foo_rs->order_by('!col1')       # ->order_by({ -desc => 'col1' })
 $foo_rs->order_by('col1,col2')   # ->order_by([qw(col1 col2)])
 $foo_rs->order_by('col1,!col2')  # ->order_by([{ -asc => 'col1' }, { -desc => 'col2' }])
 $foo_rs->order_by(qw(col1 col2)) # ->order_by([qw(col1 col2)])

Can mix it all up as well:

 $foo_rs->order_by(qw(col1 col2 col3), 'col4,!col5')

=method hri

 $foo_rs->hri;

 # equivalent to...
 $foo_rs->search(undef, {
    result_class => 'DBIx::Class::ResultClass::HashRefInflator'
 });

=method rows

 $foo_rs->rows(10);

 # equivalent to...
 $foo_rs->search(undef, { rows => 10 })

=method limit

This is an alias for C<rows>.

  $foo_rs->limit(10);

  # equivalent to...
  $foo_rs->rows(10);

=method has_rows

A lighter way to check the resultset contains any data rather than
calling C<< $rs->count >>.

=method page

 $foo_rs->page(2);

 # equivalent to...
 $foo_rs->search(undef, { page => 2 })

=method limited_page

 $foo_rs->limited_page(2, 3);

 # equivalent to...
 $foo_rs->search(undef, { page => 2, rows => 3 })

=method columns

 $foo_rs->columns([qw/ some column names /]);

 # equivalent to...
 $foo_rs->search(undef, { columns => [qw/ some column names /] });

=method add_columns

 $foo_rs->add_columns([qw/ some column names /]);

 # equivalent to...
 $foo_rs->search(undef, { '+columns' => [qw/ some column names /] });

=method remove_columns

 $foo_rs->remove_columns([qw/ some column names /]);

 # equivalent to...
 $foo_rs->search(undef, { remove_columns => [qw/ some column names /] });

=method prefetch

 $foo_rs->prefetch('bar');

 # equivalent to...
 $foo_rs->search(undef, { prefetch => 'bar' });

=method results_exist

 my $results_exist = $schema->resultset('Bar')->search({...})->results_exist;

 # there is no easily expressable equivalent, so this is not exactly a
 # shortcut. Nevertheless kept in this class for historical reasons

Uses C<EXISTS> SQL function to check if the query would return anything.
Usually much less resource intensive the more common C<< foo() if $rs->count >>
idiom.

=method results_exist_as_query

 ...->search(
    {},
    { '+columns' => {
       subquery_has_members => $some_correlated_rs->results_exist_as_query
    }},
 );

 # there is no easily expressable equivalent, so this is not exactly a
 # shortcut. Nevertheless kept in this class for historical reasons

The query generator behind L</results_exist>. Can be used standalone in
complex queries returning a boolean result within a larger query context.

=method null(@columns || \@columns)

 $rs->null('status');
 $rs->null(['status', 'title']);

=method not_null(@columns || \@columns)

 $rs->not_null('status');
 $rs->not_null(['status', 'title']);

=method like($column || \@columns, $cond)

 $rs->like('lyrics', '%zebra%');
 $rs->like(['lyrics', 'title'], '%zebra%');

=method not_like($column || \@columns, $cond)

 $rs->not_like('lyrics', '%zebra%');
 $rs->not_like(['lyrics', 'title'], '%zebra%');

=cut

=head1 SEE ALSO

This component is actually a number of other components put together.  It will
get more components added to it over time.  If you are worried about all the
extra methods you won't use or something, using the individual shortcuts is
a simple solution.  All the documentation will remain here, but the individual
components are:

=over 2

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::HRI>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::OrderBy>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::OrderByMagic>

(adds the "magic string" functionality to
C<DBIx::Class::Helper::ResultSet::Shortcut::OrderBy>))

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::GroupBy>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Distinct>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Rows>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Limit>

(inherits from C<DBIx::Class::Helper::ResultSet::Shortcut::Rows>)

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::HasRows>

(inherits from C<DBIx::Class::Helper::ResultSet::Shortcut::Rows>)

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Columns>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::AddColumns>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Page>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::LimitedPage>

(inherits from C<DBIx::Class::Helper::ResultSet::Shortcut::Page> and
L<DBIx::Class::Helper::ResultSet::Shortcut::Rows>)

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::ResultsExist>

=back
