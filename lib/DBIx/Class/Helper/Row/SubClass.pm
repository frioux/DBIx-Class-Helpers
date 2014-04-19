package DBIx::Class::Helper::Row::SubClass;

use strict;
use warnings;

# ABSTRACT: Convenient subclassing with DBIx::Class

use DBIx::Class::Helpers::Util qw{get_namespace_parts assert_similar_namespaces};
use DBIx::Class::Candy::Exports;

export_methods [qw(subclass generate_relationships set_table)];

sub subclass {
   my $self = shift;
   my $namespace = shift;
   $self->set_table;
   $self->generate_relationships($namespace);
}

sub generate_relationships {
   my $self = shift;
   my ($namespace) = get_namespace_parts($self);
   foreach my $rel ($self->relationships) {
      my $rel_info = $self->relationship_info($rel);
      my $class = $rel_info->{class};

      assert_similar_namespaces($self, $class);
      my (undef, $result) = get_namespace_parts($class);

      $self->add_relationship(
         $rel,
         "${namespace}::$result",
         $rel_info->{cond},
         $rel_info->{attrs}
      );
   };
}

sub set_table {
   my $self = shift;
   $self->table($self->table);
}

1;

=pod

=head1 SYNOPSIS

 # define parent class
 package ParentSchema::Result::Bar;

 use strict;
 use warnings;

 use parent 'DBIx::Class';

 __PACKAGE__->load_components('Core');

 __PACKAGE__->table('Bar');

 __PACKAGE__->add_columns(qw/ id foo_id /);

 __PACKAGE__->set_primary_key('id');

 __PACKAGE__->belongs_to( foo => 'ParentSchema::Result::Foo', 'foo_id' );

 # define subclass
 package MySchema::Result::Bar;

 use strict;
 use warnings;

 use parent 'ParentSchema::Result::Bar';

 __PACKAGE__->load_components(qw{Helper::Row::SubClass Core});

 __PACKAGE__->subclass;

or with L<DBIx::Class::Candy>:

 # define parent class
 package ParentSchema::Result::Bar;

 use DBIx::Class::Candy;

 table 'Bar'; # or use -autotable => v1, but see below

 primary_column 'id';
 column 'foo_id';

 belongs_to  foo => 'ParentSchema::Result::Foo', 'foo_id';

 # define subclass
 package MySchema::Result::Bar;

 use DBIx::Class::Candy
    -base => 'ParentSchema::Result::Bar',
    -components => ['Helper::Row::SubClass'];

 subclass;

=head1 DESCRIPTION

This component is to allow simple subclassing of L<DBIx::Class> Result classes.

B<NB:> if your parent class is defined above the C<::Result> level (and
therefore won't have a table deployed for it by default) you still need to set
the table.  (Any value such as 'Dummy' will do.  L<DBIx::Class::Candy>'s
C<autotable> functionality won't work in this case, so you should omit that and 
set the C<table> manually.)

=head1 METHODS

=head2 subclass

This is probably the method you want.  You call this in your child class and it
imports the definitions from the parent into itself.

=head2 generate_relationships

This is where the cool stuff happens.  This assumes that the namespace is laid
out in the recommended C<MyApp::Schema::Result::Foo> format.  If the parent has
C<Parent::Schema::Result::Foo> related to C<Parent::Schema::Result::Bar>, and you
inherit from C<Parent::Schema::Result::Foo> in C<MyApp::Schema::Result::Foo>, you
will automatically get the relationship to C<MyApp::Schema::Result::Bar>.

=head2 set_table

This is a super basic method that just sets the current classes' table to the
parent classes' table.

=head1 CANDY EXPORTS

If used in conjunction with L<DBIx::Class::Candy> this component will export:

=over

=item join_table

=item subclass

=item generate_relationships

=item set_table

=back

=head1 NOTE

This Component is mostly aimed at those who want to subclass parts of a schema,
maybe for sharing a login system in a few different projects.  Do not confuse
it with L<DBIx::Class::DynamicSubclass>, which solves an entirely different
problem.  DBIx::Class::DynamicSubclass is for when you want to store a few very
similar classes in the same table (Employee, Person, Boss, etc) whereas this
component is merely for reusing an existing schema.
