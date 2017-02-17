package WebService::MusicBrainz;

use strict;
use Mojo::Base -base;
use WebService::MusicBrainz::Request;
use Data::Dumper;

our $VERSION = '1.0';

has valid_resources => sub { ['area','artist','event','instrument','label','recording','release','release_group','series','work','url'] };
has request => sub { WebService::MusicBrainz::Request->new() };
# inc subqueries
has valid_artist_subqueries => sub { ['recordings','releases','release-groups','works' ] };
has valid_label_subqueries => sub { [ 'releases' ] };
has valid_recording_subqueries => sub { ['artist','releases' ] };
has valid_release_subqueries => sub { ['artist','collections','labels','recordings','release-groups' ] };
has valid_release_group_subqueries => sub { ['artist','releases' ] };

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

        $self->request()->inc(\@inc_subqueries);
    }

    my $request_json = $self->request()->result();

    return $request_json; 
}

sub is_valid_subquery {
    my $self = shift;
    my $search_resource = shift;
    my $search_subquery = shift;

    my $valid_method = 'valid_' . $search_resource . '_subqueries';

    my $valid_subquery_list = $self->$valid_method();

    my $valid_subquery = 0;

    if($valid_subquery_list && scalar(@{ $valid_subquery_list }) > 0) {
        if(! grep /^$search_subquery$/, @{ $valid_subquery_list }) {
             warn "Invalid subquery ($search_subquery) for the resource ($search_resource)";
        } else {
             $valid_subquery = 1;
        }
    }

    return $valid_subquery;
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
