# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 58;
BEGIN { use_ok('WebService::MusicBrainz::Release') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $sleep_duration = 2;

# TEST SEARCH API

my $ws = WebService::MusicBrainz::Release->new();
ok( $ws, "2 - get release web service object" );

my $search_title = $ws->search({ TITLE => 'Highway to Hell' });
ok( $search_title, "3 - title search response object" );

my $title_release_list = $search_title->release_list();
ok( $title_release_list, "4 - title search release list" );

my $title_releases = $title_release_list->releases();
ok( $title_releases, "5 - title search releases" );

my $title_first_release = shift @$title_releases;
ok( $title_first_release, "6 - title search first release" );

ok( $title_first_release->title() eq 'Highway to Hell', "7 - title search title match" );
ok( $title_first_release->text_rep_language() eq 'ENG', "8 - title search lang match" );

my $title_first_release_event_list = $title_first_release->release_event_list();
ok( $title_first_release_event_list, "9 - title search release event list" );

my $title_first_release_disc_list = $title_first_release->disc_list();
ok( $title_first_release_disc_list, "10 - title search disc list" );
ok( $title_first_release_disc_list->count() eq '10', "11 - title search release disc count");

my $title_first_release_track_list = $title_first_release->track_list();
ok( $title_first_release_track_list, "12 - title search track list" );
ok( $title_first_release_track_list->count() eq '10', "13 - title search track count" );

sleep($sleep_duration);

my $search_discid = $ws->search({ DISCID => 'XgrrQ8Npf9Uz_trPIFMrSz6Mk6Q-' });
ok( $search_discid, "14 - disc id response object" );

my $search_discid_release = $search_discid->release();
ok( $search_discid_release, "15 - discid release" );

ok( $search_discid_release->title() eq "Heartbreaker", "16 - discid title match" );
ok( $search_discid_release->score() eq "100", "17 - discid score match" );

my $search_discid_release_event_list = $search_discid_release->release_event_list();
ok( scalar( @{ $search_discid_release_event_list->events() } ) > 1, "18 - discid release event count" );

ok( $search_discid_release->disc_list()->count() eq "2", "19 - discid disc count" );
ok( scalar(@{ $search_discid_release->track_list()->tracks() }) == 15, "20 - discid track count" );

sleep($sleep_duration);

my $search_artist = $ws->search({ ARTIST => 'sleater kinney', TITLE => 'Doctor' });
ok( $search_artist, "21 - artist response object" );

my $search_artist_release = $search_artist->release();
ok( $search_artist_release, "22 - artist search release" );

foreach my $_release (@{ $search_artist->release_list()->releases() }) {
    if($_release->id() eq "3ba90142-0a08-4100-aff6-e2ac5c645fdf") {
        ok( $_release->type() eq "Album Official", "23 - artist search type match" );
        ok( $_release->score() =~ m/\d+/, "24 - artist search score match" );
        my $_events = $_release->release_event_list()->events();

        my $_event = pop @{ $_events };
        ok( $_event->date() eq "1996", "25 - artist search release event date" );
        ok( $_event->country() eq "US", "26 - artist search release country" );
        ok( $_event->label() eq "Chainsaw Records", "27 - artist search release label" );
        ok( $_event->catno() eq "CHSW 13", "28 - artist search release catno" );
        ok( $_event->barcode() eq "759718121322", "29 - artist search release barcode" );
    }
}

sleep($sleep_duration);

my $search_artist_id = $ws->search({ ARTISTID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab' });
ok( $search_artist_id, "30 - artistid response object" );

my $search_artist_id_releases = $search_artist_id->release_list()->releases();
ok( $search_artist_id_releases, "31 - artistid releases" );

foreach my $_release ( @$search_artist_id_releases ) {
    if ( $_release->id() eq "fed37cfc-2a6d-4569-9ac0-501a7c7598eb" ) {
        ok($_release->title() eq "Master of Puppets", "32 - artistid release title match" );
        ok($_release->asin() eq "B000025ZVE", "33 - artistid release ASIN match" );

        my $artist = $_release->artist();

        ok($artist->name() eq "Metallica", "34 - artistid artist name match");
        last;
    }
}

my $search_releasetypes = $ws->search({ RELEASETYPES => 'Official', TITLE => 'stunt' });
ok( $search_releasetypes, "35 - release types search" );

my $search_releasetypes_release = $search_releasetypes->release();
ok( $search_releasetypes_release, "36 - release types first release" );

sleep($sleep_duration);

ok( $search_releasetypes_release->type() eq "Album Official", "37 - release types match" );
ok( $search_releasetypes_release->title() eq "Stunt", "38 - release types release title match" );

my $search_inc_artist = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist' });
ok( $search_inc_artist, "39 - MBID inc artist" );

sleep($sleep_duration);

my $search_inc_counts = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'counts' });
ok( $search_inc_counts, "40 - MBID inc counts" );

my $search_inc_release_events = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'release-events' });
ok( $search_inc_release_events, "41 - MBID inc release events" );

sleep($sleep_duration);

my $search_inc_discs = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'discs' });
ok( $search_inc_discs, "42 - MBID inc discs" );

my $search_inc_tracks = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'tracks' });
ok( $search_inc_tracks, "43 - MBID inc tracks" );

sleep($sleep_duration);

my $search_inc_artist_rels = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'artist-rels' });
ok( $search_inc_artist_rels, "44 - MBID inc artist-rels" );

my $search_inc_release_rels = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'release-rels' });
ok( $search_inc_release_rels, "45 - MBID inc release-rels" );

sleep($sleep_duration);

my $search_inc_track_rels = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'track-rels' });
ok( $search_inc_track_rels, "46 - MBID inc track-rels" );

my $search_inc_url_rels = $ws->search({ MBID => 'fed37cfc-2a6d-4569-9ac0-501a7c7598eb', INC => 'url-rels' });
ok( $search_inc_url_rels, "47 - MBID inc URL rels" );

my $offset_release_search = $ws->search({ ARTIST => "Nickel Creek", OFFSET => 3 });
ok( $offset_release_search, "48 - artist with offset" );

my $offset_release_list = $offset_release_search->release_list();
ok( $offset_release_list->offset() eq "3", "49 - release list offset match" );
ok( $offset_release_list->count() eq "10", "50 - release list count match" );
ok( scalar(@{ $offset_release_list->releases() }) == 7, "51 - release list release count");

my $multi_relation_list = $ws->search({ MBID => '88ef66e4-9490-4b11-9f40-422c6c065e87', INC => 'artist-rels,release-rels' });
ok( $multi_relation_list );
my $multi_relation_release = $multi_relation_list->release();
ok( $multi_relation_release );
my $first_relation_list = $multi_relation_release->relation_list();
ok( $first_relation_list );
ok( $first_relation_list->relations() );
ok( $first_relation_list->relations()->[0]->type() eq "ArtDirection" );
my $all_relations_list = $multi_relation_release->relation_lists();
ok( $all_relations_list );
ok( scalar(@$all_relations_list) > 0 );
