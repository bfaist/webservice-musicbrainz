# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 19;
BEGIN { use_ok('WebService::MusicBrainz::Track') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# TEST SEARCH API

my $sleep_duration = 2;

my $ws = WebService::MusicBrainz::Track->new();
ok( $ws );

my $search_title = $ws->search({ TITLE => 'when the stars go blue' });
ok( $search_title );

my $search_artist = $ws->search({ ARTIST => 'Ryan Adams', TITLE => 'when the stars go blue' });
ok( $search_artist );

# my $search_release = $ws->search({ RELEASE => 'Gold', TITLE => 'when the stars go blue' });
# ok( $search_release );

sleep($sleep_duration);

my $search_duration = $ws->search({ DURATION => 200000, TITLE => 'when the stars go blue' });
ok( $search_duration );

# my $search_track_num = $ws->search({ TRACKNUM => 7, TITLE => 'Eveline' });
# ok( $search_track_num );

my $search_artist_id = $ws->search({ ARTISTID => 'c80f38a6-9980-485d-997c-5c1a9cbd0d64', TITLE => 'when the stars go blue' });
ok( $search_artist_id );

my $search_release_id = $ws->search({ RELEASEID => '433adbc2-382f-4f3a-9ce9-401f221f5b3b', TITLE => 'when the stars go blue' });
ok( $search_release_id );

sleep($sleep_duration);

# TODO: find a PUID
# my $search_puid = $ws->search({ PUID => '', TITLE => 'when the stars go blue' });
# ok( $search_puid );

my $search_limit = $ws->search({ LIMIT => 5, TITLE => 'when the stars go blue' });
ok( $search_limit );

my $search_inc_artist = $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'artist' });
ok( $search_inc_artist );

sleep($sleep_duration);

my $search_inc_releases = $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'releases' });
ok( $search_inc_releases );

sleep($sleep_duration);

# TODO: Valid option??
my $search_inc_puids = $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'puids' });
ok( $search_inc_puids );
my $puid_list = $search_inc_puids->track()->puid_list();
foreach my $puid (@{ $puid_list->puids() }) {
    if($puid->id() eq "316dd794-655f-c2a2-1ed9-6cf614b02f00") {
        ok($puid);
    }
}

my $search_inc_artist_rels = $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'artist-rels' });
ok( $search_inc_artist_rels );

my $search_inc_release_rels = $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'release-rels' });
ok( $search_inc_release_rels );

sleep($sleep_duration);

my $search_inc_track_rels = $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'track-rels' });
ok( $search_inc_track_rels );

sleep($sleep_duration);

my $search_inc_urls_rels = $ws->search({ MBID => 'bd08eddf-b811-4653-b56b-892292c291bc', INC => 'url-rels' });
ok( $search_inc_urls_rels );

my $offset_track_search = $ws->search({ TITLE => "Blue", OFFSET => 1000 });
ok( $offset_track_search );

sleep($sleep_duration);

my $offset_track_list = $offset_track_search->track_list();
ok( $offset_track_list->offset() eq "1000" );
ok( $offset_track_list->count() > 25000 );

# TEST RESPONSE OBJECT API
