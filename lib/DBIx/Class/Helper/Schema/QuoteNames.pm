package DBIx::Class::Helper::Schema::QuoteNames;

# ABSTRACT: force C<quote_names> on

use strict;
use warnings;

use DBIx::Class::Helpers::Util 'normalize_connect_info';

sub connection {
   my $self = shift;

   my $args = normalize_connect_info(@_);
   $args->{quote_names} = 1;

   $self->next::method($args)
}

1;

=head1 SYNOPSIS

 package MyApp::Schema;

 __PACKAGE__->load_components('Helper::Schema::QuoteNames');

=head1 DESCRIPTION

This helper merely forces C<quote_names> on, no matter how your settings are
configured.  You should use it.
