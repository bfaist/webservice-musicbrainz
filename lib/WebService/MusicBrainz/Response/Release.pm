package WebService::MusicBrainz::Response::Release;

use strict;
use base 'Class::Accessor';

our $VERSION = '0.92';

=head1 NAME

WebService::MusicBrainz::Response::Release

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

All the methods listed below are accessor methods.  They can take a scalar argument to set the state of the object or without and argument, they will return that state if it is available.

=head2 id()

=head2 type()

=head2 title()

=head2 text_rep_language()

=head2 text_rep_script()

=head2 asin()

=head2 artist()

=head2 release_event_list()

=head2 disc_list()

=head2 puid_list()

=head2 track_list()

=head2 relation_list()

=head2 relation_lists()

=head2 tag_list()

=head2 user_tag_list()

=head2 rating()

=head2 user_rating()

=head2 score()

=cut

__PACKAGE__->mk_accessors(qw/id type title text_rep_language text_rep_script asin artist release_group release_event_list disc_list puid_list track_list relation_list relation_lists tag_list user_tag_list rating user_rating score/);

=head1 AUTHOR

=over 4

=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2009 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
