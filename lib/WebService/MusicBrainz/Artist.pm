package WebService::MusicBrainz::Artist;

use strict;
use WebService::MusicBrainz::Query;

our $VERSION = '0.92';

=head1 NAME

WebService::MusicBrainz::Artist

=head1 SYNOPSIS

    use WebService::MusicBrainz::Artist;

    my $ws = WebService::MusicBrainz::Artist->new();

    my $response = $ws->search({ NAME => 'white lion' });

    my $artist = $response->artist(); # get first in list

    print $artist->name(), " ", $artist->life_span_begin(), "-", $artist->life_span_end(), "\n";

    # OUTPUT: White Lion 1983-1991

=head1 DESCRIPTION

This module is used to query an artist from the MusicBrainz web service.

=head1 METHODS

=head2 new()

This method is the constructor and it will make a call for initialization.  This method will take an optional HOST parameter to specify a mirrored server.  The default is "musicbrainz.org".  

my $ws = WebService::MusicBrainz::Artist->new(HOST => 'de.musicbrainz.org');

=cut

sub new {
   my $class = shift;
   my $self = {};

   bless $self, $class;

   $self->_init(@_);

   return $self;
}

sub _init {
   my $self = shift;

   my $q = WebService::MusicBrainz::Query->new(@_);

   $q->set_url_params(qw/mbid name limit offset query/);
   $q->set_inc_params(qw/aliases release-groups artist-rels release-rels track-rels url-rels sa- va- label-rels tags ratings user-tags user-ratings counts release-events discs labels/);

   $self->{_query} = $q;
}

=head2 query()

This method returns the cached WebService::MusicBrainz::Query object.

=cut

sub query {
   my $self = shift;

   return $self->{_query};
}

=head2 search()

This method will perform the search of the MusicBrainz database through their web service schema and return a
response object.

    my $ws = WebService::MusicBrainz::Artist->new();
    
    my $response = $ws->search({ MBID => 'd15721d8-56b4-453d-b506-fc915b14cba2' });
    my $response = $ws->search({ NAME => 'throwing muses' });
    my $response = $ws->search({ NAME => 'james', LIMIT => 5 });
    my $response = $ws->search({ NAME => 'beatles', OFFSET => 5 });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'artist-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'url-rels' });

Multiple INC params can be delimited by whitespace, commas, or + characters.

    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases url-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases,url-rels' });
    my $response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'aliases+url-rels' });

=head3 Find a single artist by MBID

my $mbid_response = $ws->search({ MBID => '4eca1aa0-c79f-481b-af8a-4a2d6c41aa5c' });

=head3 Find a artist(s) by name

my $name_response = $ws->search({ NAME => 'Pantera' });

=head3 Find a artist(s) by name and limit results

my $name_limit_response = $ws->search({ NAME => 'Elvis', LIMIT => 3 });

=head3 Find a artist(s) by name and offset

my $name_offset_response = $ws->search({ NAME => 'Elvis', OFFSET => 10 });

=head3 Find a artist by MBID and include aliases

my $mbid_aliases_response = $ws->search({ MBID => '070d193a-845c-479f-980e-bef15710653e', INC => 'aliases' });

=head3 Find a artist by MBID and include release groups

my $mbid_release_groups_response = $ws->search({ MBID => '4dca4bb2-23ba-4103-97e6-5810311db33a', INC => 'release-groups sa-Album' });

=head3 Find a artist by MBID and include artist relations

my $mbid_artist_rels_response = $ws->search({ MBID => 'ae1b47d5-5128-431c-9d30-e08fd90e0767', INC => 'artist-rels' });

=head3 Find a artist by MBID and include label relations

my $mbid_label_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'label-rels+sa-Official' });

=head3 Find a artist by MBID and include release relations

my $mbid_release_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });

=head3 Find a artist by MBID and include track relations

my $mbid_track_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });

=head3 Find a artist by MBID and include URL relations

my $mbid_url_rels_response = $ws->search({ MBID => 'ae1b47d5-5128-431c-9d30-e08fd90e0767', INC => 'url-rels' });

=head3 Find a artist by MBID and include tags

my $mbid_tags_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'tags' });

=head3 Find a artist by MBID and include ratings

my $mbid_ratings_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'ratings' });

=head3 Find a artist by MBID and include counts

my $mbid_counts_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'counts+sa-Official' });

=head3 Find a artist by MBID and include release events

my $mbid_rel_events_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-events+sa-Official' });

=head3 Find a artist by MBID and include discs

my $mbid_discs_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'discs+sa-Official' });

=head3 Find a artist by MBID and include labels

my $mbid_labels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'labels+release-events+sa-Official' });

=head3 Find a artist by direct Lucene query

my $q1_response = $ws->search({ QUERY => 'begin:1990 AND type:group'});

=cut

sub search {
   my $self = shift;
   my $params = shift;

   my $response = $self->query()->get('artist', $params);    

   return $response;
}

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
