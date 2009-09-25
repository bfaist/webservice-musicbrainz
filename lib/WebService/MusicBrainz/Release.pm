package WebService::MusicBrainz::Release;

use strict;
use WebService::MusicBrainz::Query;

our $VERSION = '0.22';

=head1 NAME

WebService::MusicBrainz::Release

=head1 SYNOPSIS

    use WebService::MusicBrainz::Release;
    
    my $ws = WebService::MusicBrainz::Release->new();
    
    my $response = $ws->search({ TITLE => 'ok computer' });

    my $release = $response->release(); # grab first one in the list

    print $release->title(), " (", $release->type(), ") - ", $release->artist()->name(), "\n";

    # OUTPUT: OK Computer (Album Official) - Radiohead

=head1 DESCRIPTION

=head1 METHODS

=head2 new()

This method is the constructor and it will call for  initialization.

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

   $q->set_url_params(qw/mbid title discid artist artistid releasetypes count date asin lang script cdstubs limit offset query/);
   $q->set_inc_params(qw/artist counts release-events discs tracks artist-rels release-rels track-rels url-rels/);

   $self->{_query} = $q;
}

=head2 query()

This method will return the cached query object;

=cut

sub query {
   my $self = shift;

   return $self->{_query};
}

=head2 search()

This method is used to search the MusicBrainz database using their web service schema.  The only argument is a hashref
to define the search parameters.

    my $ws = WebService::MusicBrainz::Release->new();
    
    my $response = $ws->search({ TITLE => 'Highway to Hell' });
    my $response = $ws->search({ ARTIST => 'sleater kinney' });
    my $response = $ws->search({ ARTIST => 'beatles', OFFSET => 4 });
    my $response = $ws->search({ ARTISTID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab' });
    my $response = $ws->search({ DISCID => 'XgrrQ8Npf9Uz_trPIFMrSz6Mk6Q-' });
    my $response = $ws->search({ RELEASETYPES => 'Official', MBID => 'a89e1d92-5381-4dab-ba51-733137d0e431' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'counts' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'release-events' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'discs' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'tracks' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'release-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'track-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'url-rels' });

Multiple INC params can be delimited by whitespace, commas, or + characters.

    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist url-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist,url-rels' });
    my $response = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist+url-rels' });

=cut

sub search {
   my $self = shift;
   my $params = shift;

   my $response = $self->query()->get('release', $params);    

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
