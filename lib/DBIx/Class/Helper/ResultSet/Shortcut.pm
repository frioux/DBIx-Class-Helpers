package DBIx::Class::Helper::ResultSet::Shortcut;

# ABSTRACT: Shortcuts to common searches (->order_by, etc)

use strict;
use warnings;

# VERSION

use base 'Class::C3::Componentised';

__PACKAGE__->load_components(qw(
   HRI
   OrderBy
   GroupBy
   Distinct
   Rows
   HasRows
   Limit
   Columns
   AddColumns
));

sub component_base_class { 'DBIx::Class::Helper::ResultSet::Shortcut' }

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

=method columns

 $foo_rs->columns([qw/ some column names /]);

 # equivalent to...
 $foo_rs->search(undef, { columns => [qw/ some column names /] });

=method add_columns

 $foo_rs->add_columns([qw/ some column names /]);

 # equivalent to...
 $foo_rs->search(undef, { '+columns' => [qw/ some column names /] });

=head1 SEE ALSO

This component is actually a number of other components put together.  It will
get more components added to it over time.  If you are worried about all the
extra methods you won't use or something, using the individual shortcuts is
a simple solution.  All the documentation will remain here, but the individual
components are:

=over 2

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::HRI>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::OrderBy>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::GroupBy>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Distinct>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Rows>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Limit>

(inherits from C<DBIx::Class::Helper::ResultSet::Shortcut::Rows>)

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::HasRows>

(inherits from C<DBIx::Class::Helper::ResultSet::Shortcut::Rows>)

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::Columns>

=item * L<DBIx::Class::Helper::ResultSet::Shortcut::AddColumns>

=back
