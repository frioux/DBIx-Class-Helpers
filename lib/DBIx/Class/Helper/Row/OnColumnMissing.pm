package DBIx::Class::Helper::Row::OnColumnMissing;

# ABSTRACT: Configurably handle access of missing columns

use strict;
use warnings;

use parent 'DBIx::Class::Row';

sub on_column_missing { 'warn' }

sub on_column_missing_die  {  die "Column $_[1] has not been loaded" }
sub on_column_missing_warn { warn "Column $_[1] has not been loaded" }
sub on_column_missing_nothing {}

sub get_column {
   my ($self, $column_name) = @_;

   if ($self->has_column_loaded($column_name)) {
      $self->next::method($column_name)
   } else {
      my $action = $self->on_column_missing;
      unless (ref $action) {
         $action = "on_column_missing_$action" unless ref $action;
         $action = $self->can($action);
      }
      scalar $self->$action($column_name)
   }
}


1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::Result::Account;

 use parent 'DBIx::Class::Core';

 __PACKAGE__->load_components(qw(Helper::Row::OnColumnMissing));

 __PACKAGE__->table('Account');

 __PACKAGE__->add_columns(
    id => {
       data_type         => 'integer',
       is_auto_increment => 1,
    },
    name => {
       data_type => 'varchar',
       size => 25,
    },
    book => { data_type => 'text' },
 );

 sub on_column_missing { 'die' }

 1;

Or with L<DBIx::Class::Candy>:

 package MyApp::Schema::Result::Account;

 use DBIx::Class::Candy -components => ['Helper::Row::OnColumnMissing'];

 table 'Account';

 column id => {
    data_type         => 'integer',
    is_auto_increment => 1,
 };

 column amount => {
    data_type          => 'float',
    keep_storage_value => 1,
 };

 column book => { data_type => 'text' };

 sub on_column_missing { 'die' }

 1;

Elsewhere:

 my $row = $rs->search(undef, { columns => [qw( id name )] })->one_row;

 $row->book # dies

=head1 DESCRIPTION

This module is written to handle the odd condition where you have limited the
columns retrieved from the database but accidentally access one of the ones not
included.  It is configurable by tweaking the C<on_column_missing> return value.

=head1 MODES

You specify the C<mode> by returning the C<mode> from the C<on_column_missing>
method.  By default the C<mode> returned is C<warn>.

The predefined modes are:

=over 2

=item C<die>

Dies with C<Column $name has not been loaded>.

=item C<warn>

Warns with C<Column $name has not been loaded>.

=item C<nothing>

Does nothing

=back

You can predefine more modes by defining methods named C<on_column_$mode>, and
also override the default modes by overriding the corresponding methods.  If you
need ad-hoc behavior you can return a code reference and that will be called as
a method on the object.

=head2 ADVANCED USAGE

If for some reason you find that you need to change your C<mode> at runtime, you
can always replace the C<on_column_missing> with an accessor.  For example:

 __PACKAGE__->mk_group_accessors(inherited => 'on_column_missing');
 __PACKAGE__->on_column_missing('warn');

Elsewhere:

 $row->on_column_missing('die');

If you are especially crazy you could even do something like this:

 $row->on_column_missing(sub {
    my ($self, $column) = @_;

    $self
       ->result_source
       ->resultset
       ->search({ id => $self->id })
       ->get_column($column)
       ->single
 });

Though if you do that I would make it a named mode (maybe C<retrieve>?)

=head1 THANKS

Thanks L<ZipRecruiter|https://www.ziprecruiter.com> for funding the development
of this module.
