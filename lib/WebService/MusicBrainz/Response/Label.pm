package WebService::MusicBrainz::Response::Label;

use strict;
use base 'Class::Accessor';

our $VERSION = '0.22';

=head1 NAME

WebService::MusicBrainz::Response::Label

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

All the methods listed below are accessor methods.  They can take a scalar argument to set the state of the object or without an argument, they will return that state if it is available.

=head2 id()

=head2 type()

=head2 name()

=head2 sort_name()

=head2 label_code()

=head2 disambiguation()

=head2 country()

=head2 life_span_begin()

=head2 life_span_end()

=head2 alias_list()

=head2 release_list()

=head2 relation_list()

=head2 relation_lists()

=head2 tag_list()

=head2 score()

=cut

__PACKAGE__->mk_accessors(qw/id type name sort_name label_code disambiguation country life_span_begin life_span_end alias_list release_list relation_list relation_lists tag_list score/);

=head1 AUTHOR

=over 4

=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2007 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
