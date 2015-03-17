package DBIx::Class::Helper::Row::JoinTable;

use strict;
use warnings;

use parent 'DBIx::Class::Row';

use DBIx::Class::Helpers::Util 'get_namespace_parts';
use Lingua::EN::Inflect ();
use String::CamelCase ();
use DBIx::Class::Candy::Exports;

export_methods [qw(
   join_table
   generate_primary_key
   generate_has_manys
   generate_many_to_manys
   generate_relationships
   set_table
   add_join_columns
)];

sub _pluralize {
   my $self = shift;
   my $original = shift or return;
   return join q{_}, split /\s+/,
      Lingua::EN::Inflect::PL(join q{ }, split /_/, $original);
}

sub _defaults {
   my ($self, $params) = @_;

   $params->{namespace}           ||= [ get_namespace_parts($self) ]->[0];
   $params->{left_method}         ||= String::CamelCase::decamelize($params->{left_class});
   $params->{right_method}        ||= String::CamelCase::decamelize($params->{right_class});
   $params->{self_method}         ||= String::CamelCase::decamelize($self);
   $params->{left_method_plural}  ||= $self->_pluralize($params->{left_method});
   $params->{right_method_plural} ||= $self->_pluralize($params->{right_method});
   $params->{self_method_plural}  ||= $self->_pluralize($params->{self_method});

   return $params;
}

sub join_table {
   my ($self, $params) = @_;

   $self->set_table($params);
   $self->add_join_columns($params);
   $self->generate_relationships($params);
   $self->generate_primary_key($params);
}

sub generate_primary_key {
   my ($self, $params) = @_;

   $self->_defaults($params);
   $self->set_primary_key("$params->{left_method}_id", "$params->{right_method}_id");
}

sub generate_has_manys {
   my ($self, $params) = @_;

   $params = $self->_defaults($params);
   "$params->{namespace}::$params->{left_class}"->has_many(
      $params->{self_method} =>
      $self,
      "$params->{left_method}_id"
   );

   "$params->{namespace}::$params->{right_class}"->has_many(
      $params->{self_method} =>
      $self,
      "$params->{right_method}_id"
   );
}

sub generate_many_to_manys {
   my ($self, $params) = @_;
   $params = $self->_defaults($params);

   "$params->{namespace}::$params->{left_class}"->many_to_many(
      $params->{right_method_plural} =>
      $params->{self_method},
      $params->{right_method}
   );

   "$params->{namespace}::$params->{right_class}"->many_to_many(
      $params->{left_method_plural} =>
      $params->{self_method},
      $params->{left_method}
   );
}

sub generate_relationships {
   my ($self, $params) = @_;

   $params = $self->_defaults($params);
   $self->belongs_to(
      $params->{left_method} =>
      "$params->{namespace}::$params->{left_class}",
      "$params->{left_method}_id"
   );
   $self->belongs_to(
      $params->{right_method} =>
      "$params->{namespace}::$params->{right_class}",
      "$params->{right_method}_id"
   );
}

sub set_table {
   my ($self, $params) = @_;

   $self->table("$params->{left_class}_$params->{right_class}");
}

sub _add_join_column {
   my ($self, $params) = @_;

   my $class = $params->{class};
   my $method = $params->{method};

   my $default = {
      data_type   => 'integer',
      is_nullable => 0,
      is_numeric  => 1,
   };

   $self->ensure_class_loaded($class);
   my @datas = qw{is_nullable extra data_type size is_numeric};

   my @class_column_info = (
      map {
         my $info = $class->column_info($_);
         my $result = {};
         my $defined = undef;
         for (@datas) {
            if (defined $info->{$_}) {
               $defined = 1;
               $result->{$_} = $info->{$_};
            }
         }
         $result = $default unless $defined;
         $result;
      } $class->primary_columns
   );

   if (@class_column_info == 1) {
      $self->add_columns(
         "${method}_id" => $class_column_info[0],
      );
   } else {
      my $i = 0;
      for (@class_column_info) {
         $i++;
         $self->add_columns(
            "${method}_${i}_id" => $_
         );
      }
   }
}

sub add_join_columns {
   my ($self, $params) = @_;

   $params = $self->_defaults($params);

   my $l_class = "$params->{namespace}::$params->{left_class}";
   my $r_class = "$params->{namespace}::$params->{right_class}";

   $self->_add_join_column({
      class => $l_class,
      method => $params->{left_method}
   });

   $self->_add_join_column({
      class => $r_class,
      method => $params->{right_method}
   });
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::Result::Foo_Bar;

 __PACKAGE__->load_components(qw{Helper::Row::JoinTable Core});

 __PACKAGE__->join_table({
    left_class   => 'Foo',
    left_method  => 'foo',
    right_class  => 'Bar',
    right_method => 'bar',
 });

 # the above is the same as:

 __PACKAGE__->table('Foo_Bar');
 __PACKAGE__->add_columns(
    foo_id => {
       data_type         => 'integer',
       is_nullable       => 0,
       is_numeric        => 1,
    },
    bar_id => {
       data_type         => 'integer',
       is_nullable       => 0,
       is_numeric        => 1,
    },
 );

 $self->set_primary_key(qw{foo_id bar_id});

 __PACKAGE__->belongs_to( foo => 'MyApp::Schema::Result::Foo' 'foo_id');
 __PACKAGE__->belongs_to( bar => 'MyApp::Schema::Result::Bar' 'bar_id');

or with L<DBIx::Class::Candy>:

 package MyApp::Schema::Result::Foo_Bar;

 use DBIx::Class::Candy -components => ['Helper::Row::JoinTable'];

 join_table {
    left_class   => 'Foo',
    left_method  => 'foo',
    right_class  => 'Bar',
    right_method => 'bar',
 };

=head1 METHODS

All the methods take a configuration hashref that looks like the following:

 {
    left_class          => 'Foo',
    left_method         => 'foo',     # see NOTE
    left_method_plural  => 'foos',    # see NOTE, not required, used for
                                      # many_to_many rel name in right_class
                                      # which is not generated by default
    right_class         => 'Bar',
    right_method        => 'bar',     # see NOTE
    right_method_plural => 'bars',    # see NOTE, not required, used for
                                      # many_to_many rel name in left_class
                                      # which is not generated by default
    namespace           => 'MyApp',   # default is guessed via *::Foo
    self_method         => 'foobars', # not required, used for setting the name of the
                                      # join table's relationship in a has_many
                                      # which is not generated by default
 }

=head2 join_table

This is the method that you probably want.  It will set your table, add
columns, set the primary key, and set up the relationships.

=head2 add_join_columns

Adds two non-nullable integer fields named C<"${left_method}_id"> and
C<"${right_method}_id"> respectively.

=head2 generate_has_manys

Installs methods into C<left_class> and C<right_class> to get to the join table.
The methods will be named what's passed into the configuration hashref as
C<self_method>.

=head2 generate_many_to_manys

Installs many_to_many methods into C<left_class> and C<right_class>.  The
methods will be named what's passed into the configuration hashref as
C<left_method_plural> for the C<right_class> and C<right_method_plural> for the
C<left_class>.

=head2 generate_primary_key

Sets C<"${left_method}_id"> and C<"${right_method}_id"> to be the primary key.

=head2 generate_relationships

This adds relationships to C<"${namespace}::Schema::Result::$left_class"> and
C<"${namespace}::Schema::Result::$left_class"> respectively.

=head2 set_table

This method sets the table to "${left_class}_${right_class}".

=head1 CANDY EXPORTS

If used in conjunction with L<DBIx::Class::Candy> this component will export:

=over

=item join_table

=item generate_primary_key

=item generate_has_manys

=item generate_many_to_manys

=item generate_relationships

=item set_table

=item add_join_columns

=back

=head2 NOTE

This module uses L<String::CamelCase> to default the method names and uses
L<Lingua::EN::Inflect> for pluralization.

=head1 CHANGES BETWEEN RELEASES

=head2 Changes since 0.*

Originally this module would use

       data_type         => 'integer',
       is_nullable       => 0,
       is_numeric        => 1,

for all joining columns.  It now infers C<data_type>, C<is_nullable>,
C<is_numeric>, and C<extra> from the foreign tables.
