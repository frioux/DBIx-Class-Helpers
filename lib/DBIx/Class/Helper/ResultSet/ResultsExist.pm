package DBIx::Class::Helper::ResultSet::ResultsExist;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub results_exist_as_query {
   my $self = shift;

   my $reified = $self->get_column( \1 )->as_query;

   $$reified->[0] = "( SELECT EXISTS $$reified->[0] )";

   $reified;
}

sub results_exist {
   my $self = shift;

   my( undef, $sth ) = $self->result_source
                             ->schema
                              ->storage
                               ->_select(
                                  $self->results_exist_as_query,
                                  \'*',
                                  {},
                                  {}
                               );

   my $rv = $sth->fetchall_arrayref;
   $rv->[0][0] ? 1 : 0;
}

1;

# XXX docs
