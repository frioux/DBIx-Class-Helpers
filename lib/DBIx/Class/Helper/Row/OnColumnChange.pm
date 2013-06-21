package DBIx::Class::Helper::Row::OnColumnChange;

use strict;
use warnings;

# ABSTRACT: Do things when the values of a column change

# VERSION

use parent 'DBIx::Class::Helper::Row::StorageValues';
use List::Util 'first';
use DBIx::Class::Candy::Exports;
use namespace::clean;

export_methods [qw(before_column_change around_column_change after_column_change)];

__PACKAGE__->mk_group_accessors(inherited => $_)
   for qw(_before_change _around_change _after_change);

sub before_column_change {
   die 'Invalid number of arguments. One $column => $args pair at a time.'
      unless  @_ == 3;

   my $self = shift;

   my $column   = shift;
   my $args     = shift;

   die 'method is a required parameter' unless $args->{method};
   $args->{column} = $column;
   $args->{txn_wrap} = !!$args->{txn_wrap};

   $self->_before_change([]) unless $self->_before_change;
   push @{$self->_before_change}, $args;
}

sub around_column_change {
   die 'Invalid number of arguments. One $column => $args pair at a time.'
      unless  @_ == 3;

   my $self = shift;

   my $column   = shift;
   my $args     = shift;

   die 'no method passed!' unless $args->{method};
   $args->{column} = $column;
   $args->{txn_wrap} = !!$args->{txn_wrap};

   $self->_around_change([]) unless $self->_around_change;
   push @{$self->_around_change}, $args;
}

sub after_column_change {
   die 'Invalid number of arguments. One $column => $args pair at a time.'
      unless  @_ == 3;

   my $self = shift;

   my $column   = shift;
   my $args     = shift;

   die 'no method passed!' unless $args->{method};
   $args->{column} = $column;
   $args->{txn_wrap} = !!$args->{txn_wrap};

   $self->_after_change([]) unless $self->_after_change;
   unshift @{$self->_after_change}, $args;
}

sub update {
   my ($self, $args) = @_;

   $self->set_inflated_columns($args) if $args;

   my %dirty = $self->get_dirty_columns
     or return $self;

   my @all_before = @{$self->_before_change || []};
   my @all_around = @{$self->_around_change || []};
   my @all_after = @{$self->_after_change || []};

   # prepare functions
   my @before = grep { defined $dirty{$_->{column}} } @all_before;
   my @around = grep { defined $dirty{$_->{column}} } @all_around;
   my @after  = grep { defined $dirty{$_->{column}} } @all_after;

   my $inner = $self->next::can;

   my $final = sub { $self->$inner($args) };

   for ( reverse @around ) {
      my $fn = $_->{method};
      my $old = $self->get_storage_value($_->{column});
      my $new = $dirty{$_->{column}};
      my $old_final = $final;
      $final = sub { $self->$fn($old_final, $old, $new) };
   }

   # do we wrap it in a transaction?
   my $txn_wrap = first { defined $dirty{$_->{column}} && $_->{txn_wrap} }
      @all_before, @all_around, @all_after;

   my $guard;
   $guard = $self->result_source->schema->txn_scope_guard if $txn_wrap;

   for (@before) {
      my $fn = $_->{method};
      my $old = $self->get_storage_value($_->{column});
      my $new = $dirty{$_->{column}};
      $self->$fn($old, $new);
   }

   my $ret = $final->();

   for (@after) {
      my $fn = $_->{method};
      my $old = $self->get_storage_value($_->{column});
      my $new = $dirty{$_->{column}};
      $self->$fn($old, $new);
   }

   $guard->commit if $txn_wrap;

   $ret
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::Result::Account;

 use parent 'DBIx::Class::Core';

 __PACKAGE__->load_components(qw(Helper::Row::OnColumnChange));

 __PACKAGE__->table('Account');

 __PACKAGE__->add_columns(
    id => {
       data_type         => 'integer',
       is_auto_increment => 1,
    },
    amount => {
       data_type          => 'float',
       keep_storage_value => 1,
    },
 );

 __PACKAGE__->before_column_change(
   amount => {
      method   => 'bank_transfer',
      txn_wrap => 1,
   }
 );

 sub bank_transfer {
   my ($self, $old_value, $new_value) = @_;

   my $delta = abs($old_value - $new_value);
   if ($old_value < $new_value) {
      Bank->subtract($delta)
   } else {
      Bank->add($delta)
   }
 }

 1;

or with L<DBIx::Class::Candy>:

 package MyApp::Schema::Result::Account;

 use DBIx::Class::Candy -components => ['Helper::Row::OnColumnChange'];

 table 'Account';

 column id => {
    data_type         => 'integer',
    is_auto_increment => 1,
 };

 column amount => {
    data_type          => 'float',
    keep_storage_value => 1,
 };

 before_column_change amount => {
    method   => 'bank_transfer',
    txn_wrap => 1,
 };

 sub bank_transfer {
   my ($self, $old_value, $new_value) = @_;

   my $delta = abs($old_value - $new_value);
   if ($old_value < $new_value) {
      Bank->subtract($delta)
   } else {
      Bank->add($delta)
   }
 }

 1;

=head1 DESCRIPTION

This module codifies a pattern that I've used in a number of projects, namely
that of doing B<something> when a column changes it's value in the database.
It leverages L<DBIx::Class::Helper::Row::StorageValues> for passing in the
C<$old_value>, which do not have to use.  If you leave the
C<keep_storage_value> out of the column definition it will just pass C<undef>
in as the $old_value.  Also note the C<txn_wrap> option.  This allows you to
specify that you want the call to C<update> and the call to the method you
requested to be wrapped in a transaction.  If you end up calling more than
one method due to multple column change methods and more than one specify
C<txn_wrap> it will still only wrap once.

I've gone to great lengths to ensure that order is preserved, so C<before>
and C<around> changes are called in order of definition and C<after> changes
are called in reverse order.

To be clear, the change methods only get called if the value will be changed
after C<update> runs.  It correctly looks at the current value of the column
as well as the arguments passed to C<update>.

=method before_column_change

 __PACKAGE__->before_column_change(
   col_name => {
      method   => 'method', # <-- anything that can be called as a method
      txn_wrap => 1,        # <-- true if you want it to be wrapped in a txn
   }
 );

Note: the arguments passed to C<method> will be
C<< $self, $old_value, $new_value >>.

=method after_column_change

 __PACKAGE__->after_column_change(
   col_name => {
      method   => 'method', # <-- anything that can be called as a method
      txn_wrap => 1,        # <-- true if you want it to be wrapped in a txn
   }
 );

Note: the arguments passed to C<method> will be
C<< $self, $old_value, $new_value >>.

=method around_column_change

 __PACKAGE__->around_column_change(
   col_name => {
      method   => 'method', # <-- anything that can be called as a method
      txn_wrap => 1,        # <-- true if you want it to be wrapped in a txn
   }
 );

Note: the arguments passed to C<method> will be
C<< $self, $next, $old_value, $new_value >>.

Around is subtly different than the other two callbacks.  You B<must> call
C<$next> in your method or it will not work at all.  A silly example of how
this is done could be:

 sub around_change_name {
   my ($self, $next, $old, $new) = @_;

   my $govt_records = $self->govt_records;

   $next->();

   $govt_records->update({ name => $new });
 }

Note: the above code implies a weird database schema.  I haven't actually seen
a time when I've needed around yet, but it seems like there is a use-case.

Also Note: you don't get to change the args to C<$next>.  If you think you
should be able to, you probably don't understand what this component is for.
That or you know something I don't (equally likely.)

=head1 CANDY EXPORTS

If used in conjunction with L<DBIx::Class::Candy> this component will export:

=over

=item before_column_change

=item around_column_change

=item after_column_change

=back
