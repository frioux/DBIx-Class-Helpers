package DBIx::Class::Helper::Schema::SourceOrderer;

use Moo;
use Try::Tiny;
use Scalar::Util 'blessed';

has schema => (
   is => 'ro',
   required => 1,
   handles => {
      _source_registrations => 'source_registrations',
      _source => 'source',
      _sources => 'sources',
   },
);

sub _r_sources {
   my $self = shift;

   my %sref = %{$self->_source_registrations};

   return {
      map { $sref{$_} => $_ } keys %sref
   }
}

sub source_tree {
   my $self = shift;
   my $args = shift;

   my %limit_sources = do {
      my $l = $args->{limit_sources};
      my $ref = ref $l;

      $ref eq 'HASH' ?
         %$l
         : map { $_ => 1} @$l
   };

   my %table_monikers =
      map { $_ => 1 }
      grep { $self->_source($_)->isa('DBIx::Class::ResultSource::Table') }
      grep { !$limit_sources{$_} }
      $self->_sources;

   my %r_sources = %{$self->_r_sources};
   my %sources;
   foreach my $moniker (sort keys %table_monikers) {
       my $source = $self->_source($moniker);

       # It's possible to have multiple DBIC sources using the same table
       next if $sources{$moniker};

       $sources{$moniker}{source} = $source;

       foreach my $rel (sort $source->relationships) {
           my $rel_info = $source->relationship_info($rel);

           # FIXME - we can probably do better, at least check if it's a
           #         coderef that returns a plain hash w/ fk-fk
           # Ignore any rel cond that isn't a straight hash
           next unless ref $rel_info->{cond} eq 'HASH';

           my $relsource = try { $source->related_source($rel) };
           next unless $relsource;

           # related sources might be excluded via a {sources} filter or might be views
           next unless exists $table_monikers{$relsource->source_name};

           my $rel_moniker = $r_sources{$relsource};

           # Force the order of @cond to match the order of ->add_columns
           my $idx;
           my %other_columns_idx = map {'foreign.'.$_ => ++$idx } $relsource->columns;
           my @cond = sort { $other_columns_idx{$a} cmp $other_columns_idx{$b} } keys(%{$rel_info->{cond}});

           # Get the key information, mapping off the foreign/self markers
           my @keys = map {$rel_info->{cond}->{$_} =~ /^\w+\.(\w+)$/} @cond;

           # determine if this relationship is a self.fk => foreign.pk (i.e. belongs_to)
           my $fk_constraint;

           #first it can be specified explicitly
           if ( exists $rel_info->{attrs}{is_foreign_key_constraint} ) {
               $fk_constraint = $rel_info->{attrs}{is_foreign_key_constraint};
           }
           # it can not be multi
           elsif ( $rel_info->{attrs}{accessor}
                   && $rel_info->{attrs}{accessor} eq 'multi' ) {
               $fk_constraint = 0;
           }
           # if indeed single, check if all self.columns are our primary keys.
           # this is supposed to indicate a has_one/might_have...
           # where's the introspection!!?? :)
           else {
               $fk_constraint = not $source->_compare_relationship_keys(
                  \@keys, [$source->primary_columns]);
           }

           $sources{$moniker}{foreign_table_deps}{$rel_moniker}++
              if $fk_constraint && @keys
                 # calculate dependencies: do not consider deferrable constraints and
                 # self-references for dependency calculations
                 && !$rel_info->{attrs}{is_deferrable}
                 && $rel_moniker && $rel_moniker ne $moniker

       }
   }

   my %intermediates = (
      map { $_ => $self->_resolve_deps ($_, \%sources) } keys %sources
   );

   return {
      map {
         $_ => [ref $intermediates{$_} ? keys %{$intermediates{$_}} : () ]
      } keys %intermediates
   }
}

sub _resolve_deps {
    my ( $self, $question, $answers, $seen ) = @_;
    my $ret = {};
    $seen ||= {};
    my @deps;

    # copy and bump all deps by one (so we can reconstruct the chain)
    my %seen = map { $_ => $seen->{$_} + 1 } ( keys %$seen );
    if ( blessed($question)
        && $question->isa('DBIx::Class::ResultSource::View') )
    {
        $seen{ $question->result_class } = 1;
        @deps = keys %{ $question->{deploy_depends_on} };
    }
    else {
        $seen{$question} = 1;
        @deps = keys %{ $answers->{$question}{foreign_table_deps} };
    }

    for my $dep (@deps) {
        if ( $seen->{$dep} ) {
            return {};
        }
        my $next_dep;

        if ( blessed($question)
            && $question->isa('DBIx::Class::ResultSource::View') )
        {
            no warnings 'uninitialized';
            my ($next_dep_source_name) =
              grep {
                $question->schema->source($_)->result_class eq $dep
                  && !( $question->schema->source($_)
                    ->isa('DBIx::Class::ResultSource::Table') )
              } @{ [ $question->schema->sources ] };
            return {} unless $next_dep_source_name;
            $next_dep = $question->schema->source($next_dep_source_name);
        }
        else {
            $next_dep = $dep;
        }
        my $subdeps = $self->_resolve_deps( $next_dep, $answers, \%seen );
        $ret->{$_} += $subdeps->{$_} for ( keys %$subdeps );
        ++$ret->{$dep};
    }
    return $ret;
}

1;
