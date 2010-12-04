package Dist::Zilla::Plugin::CustomLicense;
BEGIN {
  $Dist::Zilla::Plugin::CustomLicense::VERSION = '0.1.0_02';
}
# ABSTRACT: setting legal stuff of Dist::Zilla while keeping control

use Moose;
with 'Dist::Zilla::Role::BeforeBuild';

has filename => ( is => 'ro', isa => 'Str', default => 'LEGAL' );

sub before_build {
   my ($self) = @_;
   $self->zilla()->license()->load_sections_from($self->filename());
   return $self;
}

__PACKAGE__->meta()->make_immutable();
no Moose;
1;


=pod

=head1 NAME

Dist::Zilla::Plugin::CustomLicense - setting legal stuff of Dist::Zilla while keeping control

=head1 VERSION

version 0.1.0_02

=head1 DESCRIPTION

This plugin allows using L<Software::License::Custom> to get software
licensing information from a custom file. In other terms, you can
specify C<Custom> in the license configuration inside L<dist.ini>:

   name     = Foo-Bar
   abstract = basic Bar for Foo
   author   = A.U. Thor <author@example.com>
   license  = Custom
   copyright_holder = A.U.Thor

By default the custom file
is F<LEGAL> in the main directory, but it can be configured with the
C<filename> option in the F<dist.ini> configuration file:

   [CustomLicense]
   filename = MY-LEGAL-ASPECTS

See L<Software::License::Custom> for details about how F<MY-LEGAL-ASPECTS>
should be written. Most probably you will not want to include this file
in the final distro, so you should prune it out like this:

   [PruneFiles]
   filename = MY-LEGAL-ASPECTS

=head1 METHODS

=head2 before_build

Method required by L<Dist::Zilla::Role::BeforeBuild> for this plugin to work.

=head1 AUTHOR

Flavio Poletti <polettix@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Flavio Poletti <polettix@cpan.org>.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut


__END__

