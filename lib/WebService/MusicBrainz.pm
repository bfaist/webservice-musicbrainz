package WebService::MusicBrainz;

use strict;
use Mojo::Base -base;
use WebService::MusicBrainz::Request;
use Data::Dumper;

our $VERSION = '1.0';

has valid_resources => sub { ['area','artist','event','instrument','label','recording','release','release_group','series','work','url'] };
has request => sub { WebService::MusicBrainz::Request->new() };
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

    my $request = WebService::MusicBrainz::Request->new();

    if(!grep /^$search_resource$/, @{ $self->valid_resources() }) {
        die "Not a valid resource for search ($search_resource)";
    }

    $self->request()->search_resource($search_resource);

    if(exists $search_query->{mbid}) {
        $self->request()->mbid($search_query->{mbid});
    }

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
    }

    my $request_json = $self->request()->result();

    return $request_json; 
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

=head1 METHODS

=head2 new

 my $mb = WebService::MusicBrainz->new();

=head2 search

 my $results = $mb->search($resource => { param1 => 'value1' });

 Valid values for $resource are:  area, artist, event, instrument, label, recording, release, release-group, series, work, url

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
