package DBIx::Class::Helper::ResultSet::Util;

use strict;
use warnings;

# ABSTRACT: Helper utilities for DBIx::Class ResultSets

use Sub::Exporter::Progressive -setup => {
   exports => [
      qw( correlate ),
   ],
};

sub correlate {
   my ($rs, $rel) = @_;

   my $source = $rs->result_source;
   my $rel_info = $source->relationship_info($rel);

   return $source->related_source($rel)->resultset
      ->search(scalar $source->_resolve_condition(
         $rel_info->{cond},
         "${rel}_alias",
         $rs->current_source_alias,
         $rel
      ), {
         alias => "${rel}_alias",
      })
}

1;
__END__

=pod

=head1 DESCRIPTION

These functions will slowly become the core implementations of many existing
components.  The reason for this is that often you are not able to or unwilling
to add a component to an object, as adding the component fundamentally changes
the object.  If instead you merely act on the object with a subroutine you are
not committing as seriously.

=head1 EXPORTS

=head2 correlate

 correlate($author_rs, 'books')

This function allows you to correlate a resultset with one of it's
relationships.  It takes the ResultSet and relationship name as arguments.  See
L<DBIx::Class::Helper::ResultSet::CorrelateRelationship/SYNOPSIS> for an in
depth example.
