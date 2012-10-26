package DBIx::Class::Helper::ResultSet::AttributeAccessors;

# ABSTRACT: Avoid empty search params when you modify a resultset

use strict;
use warnings;

sub distinct {
   my ( $self, $switch ) = @_;
   $self->search(undef, { distinct => defined $switch ? $switch : 1 }) 
}

sub group_by {
   shift->search(undef, { group_by => shift })
}

sub order_by {
   shift->search(undef, { order_by => shift })
}

sub hri {
   shift->search(undef, {
      result_class => 'DBIx::Class::ResultClass::HashRefInflator' })
}

sub rows {
   shift->search(undef, { rows => shift })
}

sub columns {
   shift->search(undef, { columns => shift })
}

sub add_columns {
   shift->search(undef, { '+columns' => shift })
}

1;

=pod

=head1 SYNOPSIS

 package MyApp::Schema::ResultSet::Foo;

 __PACKAGE__->load_components(qw{Helper::ResultSet::AttributeAccessors});

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

=method columns

 $foo_rs->columns([qw/ some column names /]);

 # equivalent to...
 $foo_rs->search(undef, { columns => [qw/ some column names /] });

=method add_columns

 $foo_rs->add_columns([qw/ some column names /]);

 # equivalent to...
 $foo_rs->search(undef, { '+columns' => [qw/ some column names /] });

