package WebService::MusicBrainz::Artist;

use strict;
use WebService::MusicBrainz::Query;

our $VERSION = '0.20';

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

   $q->set_url_params(qw/mbid name limit offset/);
   $q->set_inc_params(qw/aliases artist-rels release-rels track-rels url-rels sa- va-/);

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

Copyright 2006-2007 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
