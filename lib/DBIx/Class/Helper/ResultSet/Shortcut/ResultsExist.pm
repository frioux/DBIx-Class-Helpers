package DBIx::Class::Helper::ResultSet::Shortcut::ResultsExist;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub results_exist_as_query {
   my ($self, $cond) = @_;


   my $reified = $self->search_rs( $cond, {
      columns => { _results_existence_check => \ '42' }
   } )->as_query;


   $$reified->[0] = "( SELECT EXISTS $$reified->[0] )";


   $reified;
}


sub results_exist {
   my ($self, $cond) = @_;

   my $query = $self->results_exist_as_query($cond);
   $$query->[0] .= ' AS _existence_subq';

   my( undef, $sth ) = $self->result_source
                             ->schema
                              ->storage
                               ->_select(
                                 $query,
                                  \'*',
                                  {},
                                  {},
                               );

   $sth->fetchall_arrayref->[0][0] ? 1 : 0;
}

1;
