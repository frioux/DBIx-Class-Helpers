package inc::Dist::Zilla::Plugin::DBICSgen;

use strict;
use warnings;

# ABSTRACT: common tests to check syntax of your modules

use Moose;
use Module::Runtime 'use_module';
require lib;

with 'Dist::Zilla::Role::FileGatherer';

has schema => (
   is       => 'ro',
   isa      => 'Str',
   required => 1,
);

has lib => (
   is       => 'rw',
   isa      => 'ArrayRef',
   default  => sub { [qw{lib}] },
);

sub mvp_multivalue_args { qw(lib) }

unlink 't/lib/ddl.sql';

sub gather_files {
   my $self = shift;

   lib->import(@{$self->lib});

   my $schema = $self->schema;
   use_module($schema);

   $schema->generate_ddl;

   my $file = Dist::Zilla::File::OnDisk->new(name => $schema->ddl_filename);
   $self->add_file($file);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=begin Pod::Coverage

gather_files
mvp_multivalue_args

=end Pod::Coverage


=head1 SYNOPSIS

In your dist.ini:

    [CompileTests]
    skip = Test$

=head1 DESCRIPTION

This is an extension of L<Dist::Zilla::Plugin::InlineFiles>, providing
the following files:

=over 4

=item * t/00-compile.t - a standard test to check syntax of bundled modules

This test will find all modules and scripts in your dist, and try to
compile them one by one. This means it's a bit slower than loading them
all at once, but it will catch more errors.

=back


This plugin accepts the following options:

=over 4

=item * skip: a regex to skip compile test for modules matching it. The
match is done against the module name (C<Foo::Bar>), not the file path
(F<lib/Foo/Bar.pm>).

=back



