package WebService::MusicBrainz;

use strict;
use Mojo::Base -base;
use WebService::MusicBrainz::Request;
use Data::Dumper;

our $VERSION = '1.0';

has 'request';
has valid_resources => sub { ['area','artist','event','instrument','label','recording','release','release_group','series','work','url'] };
has relationships => sub {
    my $rels = ['area-rels','artist-rels','event-rels','instrument-rels','label-rels','place-rels','recording-rels','release-rels','release-group-rels','series-rels','url-rels','work-rels'];
    return $rels;
};

# inc subqueries
has subquery_map => sub {
    my %subquery_map;

    $subquery_map{artist}        = ['recordings','releases','release-groups','works'];
    $subquery_map{label}         = ['releases'];
    $subquery_map{recording}     = ['artists','releases'];
    $subquery_map{release}       = ['artists','collections','labels','recordings','release-groups' ];
    $subquery_map{release_group} = ['artists','releases'];

    return \%subquery_map;
};

has search_fields_by_resource => sub {
    my %search_fields;

    $search_fields{area}          = ['aid','alias','area','begin','comment','end','ended','sortname','iso','iso1','iso2','iso3','type'];
    $search_fields{artist}        = ['area','beginarea','endarea','arid','artist','artistaccent','alias','begin','comment','country','end','ended','gender','ipi','sortname','tag','type'];
    $search_fields{label}         = ['alias','area','begin','code','comment','country','end','ended','ipi','label','labelaccent','laid','sortname','type','tag'];
    $search_fields{recording}     = ['arid','artist','artistname','creditname','comment','country','date','dur','format','isrc','number','position','primarytype','puid','qdur','recording','recordingaccent','reid','release','rgid','rid','secondarytype','status','tid','trnum','tracks','tracksrelease','tag','type','video'];
    $search_fields{release_group} = ['arid','artist','comment','creditname','primarytype','rgid','releasegroup','releasegroupaccent','releases','release','reid','secondarytype','status','tag','type'];
    $search_fields{release}       = ['arid','artist','artistname','asin','barcode','catno','comment','country','creditname','date','discids','discidsmedium','format','laid','label','lang','mediums','primarytype','puid','quality','reid','release','releaseaccent','rgid','script','secondarytype','status','tag','tracks','tracksmedium','type'];
    $search_fields{work}         = ['alias','arid','artist','comment','iswc','lang','tag','type','wid','work','workaccent'];

    return \%search_fields;
};

has is_valid_subquery => sub { 
    my $self = shift;
    my $resource = shift;
    my $subquery_list = shift;

    my $subquery_map = $self->subquery_map(); 

    my $is_valid = 0;

    if(exists $subquery_map->{$resource}) {
        my $subquery_valid_count = 0;

        foreach my $subquery (@$subquery_list) {
            if(grep /^${subquery}$/, @{ $subquery_map->{$resource} } ||
               grep /^${subquery}$/, @{ $self->relationships() }) {
                   $subquery_valid_count += 1;
            }
        }

        if(scalar(@$subquery_list) == $subquery_valid_count) {
            $is_valid = 1;
        }
    }

    return $is_valid;
};

sub search {
    my $self = shift;
    my $search_resource = shift;
    my $search_query = shift;

    $self->request(WebService::MusicBrainz::Request->new());

    if(!grep /^$search_resource$/, @{ $self->valid_resources() }) {
        die "Not a valid resource for search ($search_resource)";
    }

    $self->request()->search_resource($search_resource);

    if(exists $search_query->{mbid}) {
        $self->request()->mbid($search_query->{mbid});
        delete $search_query->{mbid};

        # only use "inc" parameters when a specific MBID is given
        if(exists $search_query->{inc}) {
            my @inc_subqueries;

            if(ref($search_query->{inc}) eq 'ARRAY') {
                foreach my $inc_item (@{ $search_query->{inc} }) {
                     push @inc_subqueries, $inc_item;
                }
            } else {
                push @inc_subqueries, $search_query->{inc};
            }

            if($self->is_valid_subquery($search_resource, \@inc_subqueries)) {
                $self->request()->inc(\@inc_subqueries);
            } else {
                my $subquery_str = join ", ", @inc_subqueries;
                die "Not a valid \"inc\" subquery ($subquery_str) for resource: $search_resource";
            }

            delete $search_query->{inc};
        }
    }

    if(exists $search_query->{fmt}) {
        $self->request()->format($search_query->{fmt});
        delete $search_query->{fmt};
    }

    if(exists $search_query->{offset}) {
        $self->request()->offset($search_query->{offset});
        delete $search_query->{offset};
    }

    foreach my $search_field (keys %{ $search_query }) {
        if(! grep /^$search_field$/, @{ $self->search_fields_by_resource->{$search_resource} }) {
             die "Not a valid search field ($search_field) for resource \"$search_resource\"";
        }
    }

    $self->request->query_params($search_query);

    my $request_result = $self->request()->result();

    return $request_result; 
}

=head1 NAME

WebService::MusicBrainz

=head1 SYNOPSIS

    use WebService::MusicBrainz;

    my $mb_ws = WebService::MusicBrainz->new();

    my $area_result = $mb_ws->search(area => { x => 'y' });
    my $artist_result = $mb_ws->search(artist => { x => 'Y' });
    my $event_result = $mb_ws->search(event => { x => 'Y' });
    my $instrument_result = $mb_ws->search(instrument => { x => 'Y' });
    my $label_result = $mb_ws->search(label => { x => 'Y' });
    my $recording_result = $mb_ws->search(recording => { x => 'Y' });
    my $release_result = $mb_ws->search(release => { x => 'Y' });
    my $release_group_result = $mb_ws->search(release_group => { x => 'Y' });
    my $series_result = $mb_ws->search(series => { x => 'Y' });
    my $work_result = $mb_ws->search(work => { x => 'Y' });
    my $url_result = $mb_ws->search(url => { x => 'Y' });

=head1 DESCRIPTION

API to search the musicbrainz.org database

=head1 VERSION

Version 1.0 and future releases are not backward compatible with pre-1.0 releases.  This is a complete re-write using version 2.0 of the MusicBrainz API and Mojolicious.

=head1 METHODS

=head2 new

 my $mb = WebService::MusicBrainz->new();

=head2 search

 my $results = $mb->search($resource => { param1 => 'value1' });

 Valid values for $resource are:  area, artist, event, instrument, label, recording, release, release-group, series, work, url
The default is to return decoded JSON as a perl data structure.  Specify format => 'xml' to return the results as an instance of Mojo::DOM.

=head3 Search by MBID

  my $result = $mb->search($resource => { mbid => 'xxxxxx' });

=head3 Search area

  my $areas = $mb->search(area => { area => 'cincinnati' });
  my $areas = $mb->search(area => { iso => 'US-OH' });

=head3 Search artist
  
 # JSON example
 my $artists = $mb->search(artist => { artist => 'Ryan Adams', type => 'Person' }); 

 my $artist_country = $artists->{artists}->[0]->{country};

 # XML example
 my $artists = $mb->search(artist => { artist => 'Ryan Adams', type => 'Person', fmt => 'xml' }); 

 my $artist_country = $artists->at('country')->text;

=head3 Search release

 my $releases = $mb->search(release => { release => 'Love Is Hell', status => 'official' });
 print "RELEASE COUNT: ", $releases->{count}, "\n";

=head1 DEBUG

Set environment variable MUSICBRAINZ_DEBUG=1

=over 1

=item

The URL that is generated for the search will output to STDOUT.

=item

The formatted output (JSON or XML) will be output to STDOUT

=back

=head1 AUTHOR

=over 4

=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2017 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://musicbrainz.org/doc/Development/XML_Web_Service/Version_2

=cut

1;
