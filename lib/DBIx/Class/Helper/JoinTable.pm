package DBIx::Class::Helper::JoinTable;

sub join_table {
   my $self   = shift;
   my $params = shift;
   $self->set_table($params);
   $self->generate_relationships($params);
   $self->generate_primary_key($params);
   $self->generate_constraints($params);
}

sub generate_primary_key {
   my ($self, $params) = @_;
   $self->set_primary_key("$params->{left_method}_id", "$params->{right_method}_id");
}

sub generate_relationships {
   my ($self, $params) = @_;
   $self->belongs_to(
      $params->{left_method} =>
      "$params->{namespace}::Schema::Result::$params->{left_class}",
      "$params->{left_method}_id"
   );
   $self->belongs_to(
      $params->{right_method} =>
      "$params->{namespace}::Schema::Result::$params->{right_class}",
      "$params->{right_method}_id"
   );
}

sub set_table {
   my ($self, $params) = @_;
   $self->table("$params->{left_class}_$params->{right_class}");
}

sub add_join_columns {
   my ($self, $params) = @_;
   $self->add_columns(
      "$params->{left_method}_id" => {
         data_type         => 'integer',
         is_nullable       => 0,
      },
      "$params->{right_method}_id" => {
         data_type         => 'integer',
         is_nullable       => 0,
      },
   );
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::Result::Foo;

 __PACKAGE__->load_components(qw{Helper::JoinTable Core});

 __PACKAGE__->join_table({
    left_class   => 'Foo',
    left_method  => 'foo',
    right_class  => 'Bar',
    right_method => 'bar',
    namespace    => 'MyApp',
 });

 # the above is the same as:

 __PACKAGE__->table('Foo_Bar');
 __PACKAGE__->add_columns(
    foo_id => {
       data_type         => 'integer',
       is_nullable       => 0,
    },
    bar_id => {
       data_type         => 'integer',
       is_nullable       => 0,
    },
 );

 $self->set_primary_key(qw{foo_id bar_id});

 __PACKAGE__->belongs_to( foo => 'MyApp::Schema::Result::Foo' 'foo_id');
 __PACKAGE__->belongs_to( bar => 'MyApp::Schema::Result::Bar' 'bar_id');

=head1 METHODS

=head2 add_join_columns
=head2 generate_primary_key
=head2 generate_relationships
=head2 join_table
=head2 set_table

=end
