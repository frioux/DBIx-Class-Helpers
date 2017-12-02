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

   my $storage = $self->result_source->schema->storage;
   my( $sql, @bind ) = @${ $self->results_exist_as_query };

   # ugly as fuck but meh - DBIC has to do this too in places
   $sql =~ s/\A \s* \( \s* (.+) \s* \) \s* \z/$1/sx;

   my( undef, $sth ) = $storage->dbh_do( _dbh_execute =>
      $sql,
      \@bind,
      $storage->_dbi_attrs_for_bind( undef, \@bind ),
   );

   my $rv = $sth->fetchall_arrayref;
   $rv->[0][0];
}

1;
