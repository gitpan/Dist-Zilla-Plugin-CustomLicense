package Software::License::Custom;
BEGIN {
  $Software::License::Custom::VERSION = '0.1.0_02';
}
use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );
use Text::Template;

use base 'Software::License';

# ABSTRACT: custom license handler

sub new {
   my ($class, $arg) = @_;

   my $filename = delete $arg->{filename};

   my $self = $class->SUPER::new($arg);

   $self->load_sections_from($filename) if defined $filename;

   return $self;
} ## end sub new

sub load_sections_from {
   my ($self, $filename) = @_;

   # Sections are kept inside a hash
   $self->{'Software::License::Custom'}{section_for} = \my %section_for;

   my $current_section = '';
   open my $fh, '<', $filename
      or croak "open('$filename'): $OS_ERROR";
   while (<$fh>) {
      if (my ($section) = m{\A __ (.*) __ \n\z}mxs) {
         ($current_section = $section) =~ s/\W+//gmxs;
      }
      else {
         $section_for{$current_section} .= $_;
      }
   }
   close $fh;

   # strip last newline from all items
   s{\n\z}{}mxs for values %section_for;

   return $self;
}

sub section_data {
   my ($self, $name) = @_;
   my $section_for = $self->{'Software::License::Custom'}{section_for} ||= {};
   return unless exists $section_for->{$name};
   return unless defined $section_for->{$name};
   return \$section_for->{$name};
}

sub name       { shift->_fill_in('NAME') }
sub url        { shift->_fill_in('URL') }
sub meta_name  {
   my $self = shift;
   return 'custom' unless ref $self;
   return $self->_fill_in('META_NAME')
}
sub meta2_name { shift->_fill_in('META2_NAME') }
sub license    { shift->_fill_in('LICENSE') }
sub notice     { shift->_fill_in('NOTICE') }

sub fulltext {
   my ($self) = @_;
   return join "\n", $self->notice, $self->license;
}

sub version {
   my ($self) = @_;
   return unless $self->section_data('VERSION');
   return $self->_fill_in('VERSION')
}

# copied from Software::License v0.102340, copy is needed because this
# method is private and could change in future versions.
sub _fill_in {
  my ($self, $which) = @_;

  Carp::confess "couldn't build $which section" unless
    my $template = $self->section_data($which);

  return Text::Template->fill_this_in(
    $$template,
    HASH => { self => \$self },
    DELIMITERS => [ qw({{ }}) ],
  );
}

1;


=pod

=head1 NAME

Software::License::Custom - custom license handler

=head1 VERSION

version 0.1.0_02

=head1 DESCRIPTION

This module extends L<Software::License> to give the possibility of
specifying all aspects related to a software license in a custom file.
This allows for setting custom dates, notices, etc. while still preserving
compatibility with all places where L<Software::License> is used, e.g. L<Dist::Zilla>.

In this way, you should be able to customise some aspects of the licensing
messages that would otherwise be difficult to tinker, e.g. adding a note
in the notice, setting multiple years for the copyright notice or set multiple
authors and/or copyright holders.

The license details should be put inside a file that contains different
sections. Each section has the following format:

=over

=item *

header line

a line that begins and ends with two underscores C<__>. The string
between the begin and the end of the line is first depured of any
non-word character, then used as the name of the section;

=item *

body

a L<Text::Template> (possibly a plain text file) where items to be
expanded are enclosed between double braces.

=back

Each section is terminated by the header of the following section or by
the end of the file. Example:

   __[ NAME ]__
   The Foo-Bar License
   __URL__
   http://www.example.com/foo-bar.txt
   __[ META_NAME ]__
   foo_bar_meta
   __{ META2_NAME }__
   foo_bar_meta2
   __[ NOTICE ]__
   Copyright (C) 2000-2002 by P.R. Evious
   Copyright (C) {{$self->year}} by {{$self->holder}}.

   This is free software, licensed under {{$self->name}}.

   __[ LICENSE ]__
               The Foo-Bar License

   Well... this is only some sample text. I'm true... only sample text!!!

   Yes, spanning more lines and more paragraphs.

The different formats for specifying the section name in the example
above are only examples, you're invited to use a consistent approach.

=head1 METHODS

=head2 new

   my $slc = Software::License::Custom->new({filename => 'LEGAL'});

Create a new object. Arguments are passed through an anonymous hash, the
following keys are allowed:

=over

=item filename

the file where the custom software license details are written.

=back

=head2 load_sections_from

   $slc->load_sections_from('MY-LEGAL-ASPECTS');

Loads the different sections of the license from the provided filename.

Returns the input object.

=head2 section_data

   my $notice_template_reference = $slc->section_data('NOTICE');

Returns a reference to a textual template that can be fed to
L<Text::Template> (it could be simple text), according to what is
currently loaded in the object.

=head2 name

   my $name = $slc->name();

Returns the name of the license, see L<Software::License> for details.

=head2 url

   my $url = $slc->url();

Returns the URL of the license, see L<Software::License> for details.

=head2 meta_name

   my $meta_name = $slc->meta_name();

See L<Software::License>. Note that this method is a class method in
L<Software::License>, so it has been kept as a class method as well.
When called as a class method, it returns C<custom>.

=head2 meta2_name

   my $meta2_name = $slc->meta2_name();

See L<Software::License>.

=head2 license

   my $license = $slc->license();

Returns the license text, see L<Software::License> for details.

=head2 notice

   my $notice = $slc->notice();

Returns the notice text, see L<Software::License> for details.

=head2 fulltext

   my $fulltext = $slc->fulltext();

See L<Software::License> for details.

=head2 version

   my $version = $slc->version();

See L<Software::License> for details. This method replicates the semantic
of the same method from L<Software::License> as of version 0.102340.

=head1 BUGS

This module uses L<Software::License> as a base but reimplements most of
its methods to lower coupling with an implementation that could possibly
change. In particular, the C<_fill_in> method in L<Software::License>
has been copied because it's private.

It is assumed that the L<Software::License> object is a hash and that
the key C<Software::License::Custom> in this hash is free for use. These
seem to be reasonable assumptions.

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

