package DBIx::Class::Helper::Schema::Verifier::ColumnInfo;

# ABSTRACT: Verify that Results only use approved column_info keys

use strict;
use warnings;

use MRO::Compat;
use mro 'c3';

use base 'DBIx::Class::Helper::Schema::Verifier';

my @allowed_keys = (
# defaults from ::ResultSource
qw(
   accessor
   auto_nextval
   data_type
   default_value
   extra
   is_auto_increment
   is_foreign_key
   is_nullable
   is_numeric
   retrieve_on_insert
   sequence
   size
),
# ::InflateColumn::DateTime
qw(
   floating_tz_ok
   inflate_datetime
   locale
   timezone
),
# ::InflateColumn::File and ::InflateColumn::FS
qw(
   file_column_path
   fs_column_path
   fs_new_on_update
   is_file_column
   is_fs_column
),
# ::Helpers
qw(
   is_serializable
   keep_storage_value
   remove_column
) );

sub allowed_column_keys { @allowed_keys }

sub result_verifiers {
   my $self = shift;
   my %allowed = map { $_ => 1 } $self->allowed_column_keys;

   (
      sub {
         my ($s, $result, $set) = @_;
         my $column_info =  $result->columns_info;
         for my $col_name (keys %$column_info) {
            for my $key (keys %{ $column_info->{$col_name} }) {
               if (!$allowed{$key}) {
                  die sprintf join(' ', qw(Forbidden column config <%s> used in
                     column <%s> in result <%s>. You can explicitly allow it by
                     adding it to your schema's allowed_column_keys method.)),
                     $key, $col_name, $result;
               }
            }
         }
      },
      $self->next::method,
   )
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::Verifier::ColumnInfo');

 # optionally add some non-standard allowed keys
 sub allowed_column_keys {
   my $self = shift;
   my @keys = $self->next::method;
   push @keys, qw(is_serializable keep_storage_value remove_column);
   return @keys;
 }

=head1 DESCRIPTION

C<DBIx::Class::Helper::Schema::Verifier::ColumnInfo> verifies that none of your
columns use non-approved configuration keys. L<DBIx::Class> doesn't do any key
verification, so this Helper makes sure you don't get burned by a typo like
using C<autoincrement> instead of C<is_auto_increment>. If your schema uses a
non-approved column config key, it will refuse to load and instead offer a
hopefully helpful message pointing out the error.

=method allowed_column_keys()

It's entirely possible that you would like to use some non-default config keys,
especially if you use some column-extension components. Override this method in
your schema and append your new keys to the list returned by the superclass
call.  The overridden method must return a list of keys.

 sub allowed_column_keys {
   my $self = shift;
   my @keys = $self->next::method;
   # modify @keys as needed
   return @keys;
 }

