package DBIx::Class::Helper::ResultSet::ResultsExist;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub results_exist_as_query {
   my $self = shift;

   my $reified = $self->get_column( \1 )->as_query;

   # this would have been the "clean" way to do it
   # alas we can not use it - we do not know what WHERE's a fresh
   # resultset would have tacked on it via default_attrs
   #$$reified->[0] = "EXISTS $$reified->[0]";
   #
   #( $self->result_source->resultset->get_column($reified)->all )[0];

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
