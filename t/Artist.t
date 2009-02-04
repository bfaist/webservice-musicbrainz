# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 61;
BEGIN { use_ok('WebService::MusicBrainz::Artist') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $sleep_duration = 2;

my $ws = WebService::MusicBrainz::Artist->new();
ok( $ws, 'create WebService::MusicBrainz::Artist object' );

my $wsde = WebService::MusicBrainz::Artist->new(HOST => 'de.musicbrainz.org');
my $wsde_query = $wsde->query();
ok( $wsde_query->{_baseurl} =~ m/de\.musicbrainz\.org/, 'create WebService::MusicBrainz::Artist object/altername host' );

####  TEST ARTIST MBID SEARCH ###############################

my $search_mbid = $ws->search({ MBID => 'd15721d8-56b4-453d-b506-fc915b14cba2' });
ok( $search_mbid, 'get MBID search response object' );

my $artist_mbid = $search_mbid->artist();
ok( $artist_mbid, 'got artist response object' );

ok( $artist_mbid->type() eq "Group", 'check artist type' );
ok( $artist_mbid->name() eq "The Black Keys", 'check artist name');
ok( $artist_mbid->sort_name() eq "Black Keys, The", 'check artist sort name' );

####  TEST ARTIST MBID SEARCH ###############################

####  TEST ARTIST NAME SEARCH ###############################

my $search_name = $ws->search({ NAME => 'white lion' });
ok( $search_name, 'get NAME search response object' );

my $artist_name = $search_name->artist();
ok( $artist_name, 'get artist response object' );

ok( $artist_name->name() eq "White Lion", 'check artist name' );
ok( $artist_name->sort_name() eq "White Lion", 'check artist sort name' );
ok( $artist_name->life_span_begin() eq "1983", 'check artist life span begin' );
ok( $artist_name->life_span_end() eq "1991", 'check artist life span end' );

my $search_name2 = $ws->search({ NAME => 'Van Halen' });
my $artist_name2 = $search_name2->artist();
ok( $artist_name2->score() =~ m/\d+/, 'get first artist score of 100' );

sleep($sleep_duration);

####  TEST ARTIST NAME SEARCH ###############################

####  TEST ARTIST NAME LIMIT SEARCH ###############################

my $limit = 5;

my $search_name_limit = $ws->search({ NAME => 'james', LIMIT => $limit });
ok( $search_name_limit, 'get NAME, LIMIT search response object' );

my $artist_name_limit = $search_name_limit->artist_list();

ok( $artist_name_limit, 'get artist list response object' );
ok( scalar(@{ $artist_name_limit->artists() }) == $limit, 'check size of artist list matches limit' );

####  TEST ARTIST NAME LIMIT SEARCH ###############################

####  TEST ARTIST MBID ALIASES SEARCH ###############################

my $search_inc_aliases = $ws->search({ MBID => '070d193a-845c-479f-980e-bef15710653e', INC => 'aliases' });
ok( $search_inc_aliases, 'get INC aliases search response object' );

my $artist_inc_aliases = $search_inc_aliases->artist();
ok( $artist_inc_aliases, 'get artist response object' );

ok( $artist_inc_aliases->name() eq "Prince", 'check artist name' );

my $artist_alias_list = $artist_inc_aliases->alias_list();
ok( $artist_alias_list, 'get artist alias list' );

ok( scalar($artist_alias_list->aliases()) > 3, 'check size of artist alias list' );

sleep($sleep_duration);

####  TEST ARTIST MBID ALIASES SEARCH ###############################

####  TEST ARTIST MBID ARTIST RELATIONS SEARCH ###############################

my $search_inc_artist_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'artist-rels' });
ok( $search_inc_artist_rels, 'get INC artist_rels search response object' );

my $artist_inc_artist_rels = $search_inc_artist_rels->artist();
ok( $artist_inc_artist_rels, 'get artist reponse object' );

ok( $artist_inc_artist_rels->name() eq "Metallica", 'check artist name' );
ok( $artist_inc_artist_rels->sort_name() eq "Metallica", 'check artist sort name' );
ok( $artist_inc_artist_rels->life_span_begin() eq "1981-10", 'check artist life span begin' );

my $artist_inc_relation_list = $artist_inc_artist_rels->relation_list();
ok( $artist_inc_relation_list, 'get artist relation list' );

foreach my $relation (@{ $artist_inc_relation_list->relations() }) {
    my $artist = $relation->artist();

    if($artist->name() eq "Jason Newsted") {
	 ok( $relation->type() eq "MemberOfBand", 'check relation type' );
	 ok( $relation->direction() eq "backward", 'check relation direction' );
	 ok( $relation->target() eq "248ead7d-8058-4e0c-b334-fde70c036f8d", 'check relation target' );
	 ok( $relation->begin() eq "1986", 'check artist begin relation' );
	 ok( $relation->end() eq "2001", 'check artist end relation' );
         ok( $artist->sort_name() eq "Newsted, Jason", 'check artist sort name' );
	 last;
    }
}

####  TEST ARTIST MBID ARTIST RELATIONS SEARCH ###############################

####  TEST ARTIST MBID RELEASE RELATIONS SEARCH ###############################

sleep($sleep_duration);

my $search_inc_release_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });
ok( $search_inc_release_rels, 'get INC release_rels search response object' );

my $artist_inc_release_rels = $search_inc_release_rels->artist();
ok( $artist_inc_release_rels, 'get artist response object' );

my $artist_inc_release_relation_list = $artist_inc_release_rels->relation_list();
ok( $artist_inc_release_relation_list, 'get artist relation list' );

ok( scalar($artist_inc_release_relation_list->relations()) > 3, 'check size of artist relation list' );

####  TEST ARTIST MBID RELEASE RELATIONS SEARCH ###############################

sleep($sleep_duration);

my $search_inc_track_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });
ok( $search_inc_track_rels, 'get INC track_rels search response object' );
my $search_inc_track_rels_artist = $search_inc_track_rels->artist();
ok( $search_inc_track_rels_artist, 'check INC track_rels artist response' );

my $search_inc_url_rels = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'url-rels' });
ok( $search_inc_url_rels, 'get INC url_rels search response object' );

my $search_inc_url_rels_artist = $search_inc_url_rels->artist();
ok ( $search_inc_url_rels_artist, 'check INC url_rels search artist' );
my $search_inc_url_rels_artist_relation_list = $search_inc_url_rels_artist->relation_list();

foreach my $relation ( @{ $search_inc_url_rels_artist_relation_list->relations() } ) {
     if($relation->type() eq "Wikipedia") {
        ok( $relation->target() =~ m/wikipedia/, 'check INC url_rels relation url' );
     }
}

sleep($sleep_duration);

#### TEST ARTIST MBID SINGLE ARTIST RELEASE SEARCH ########################################

my $sa_album_artist_search = $ws->search({ MBID => 'abe2669a-a612-4bf6-9193-bb4f4b8a9088', INC => 'sa-Album' });
ok( $sa_album_artist_search, 'check INC sa-Album artist search object' );

my $sa_album_artist = $sa_album_artist_search->artist();
ok( $sa_album_artist, 'check INC sa-Album artist object' );

my $sa_album_artist_release_list = $sa_album_artist->release_list();

foreach my $release (@{ $sa_album_artist_release_list->releases() }) {
   if($release->id() eq "2f355069-0524-4f79-a6be-8a4ea5ff5eba") {
       ok($release->type() eq "Album Official", 'check INC sa-Album artist release type' );
       ok($release->title() eq "Whatever and Ever Amen", 'check INC sa-Album artist release type' );
       ok($release->text_rep_language() eq "ENG", 'check INC sa-Album artist release test rep language' );
       ok($release->text_rep_script() eq "Latn", 'check INC sa-Album artist release test rep script' );
   }
}

sleep($sleep_duration);

#### TEST ARTIST MBID VARIOUS ARTIST RELEASE SEARCH ############################
my $va_album_vartist_search = $ws->search({ MBID => 'c80f38a6-9980-485d-997c-5c1a9cbd0d64', INC => 'va-Soundtrack' });
ok( $va_album_vartist_search, 'check INC va_soundtrack search object' );

my $va_album_vartist_search_artist = $va_album_vartist_search->artist();
ok( $va_album_vartist_search_artist, 'check INC va_soundtrack search artist object' );

my $va_album_vartist_search_artist_release_list = $va_album_vartist_search_artist->release_list();

foreach my $release (@{ $va_album_vartist_search_artist_release_list->releases() }) {
    if($release->id() eq "c8e0d462-3634-44f5-9025-a93c5f373e1c") {
       ok( $release->type() eq "Soundtrack Official", 'check INC va_soundtrack release type' );
       ok( $release->title() eq "Elizabethtown", 'chck INC va_soundtrack release title' );
    }
}

sleep($sleep_duration);

my $offset_artist_search = $ws->search({ NAME => 'beatles', OFFSET => 3 });

ok( $offset_artist_search );

my $offset_artist_list = $offset_artist_search->artist_list();

ok( $offset_artist_list->offset() eq "3" );
ok( $offset_artist_list->count() eq "9" );

foreach my $artist (@{ $offset_artist_list->artists() }) {
   if($artist->id() eq "4c3d0136-9235-4c50-b136-be49d17163df") {
       ok($artist->name() eq "The Black Beatles");
   }
}

my $utf8_artist_test = $ws->search({ NAME => 'João Gilberto' });
ok( $utf8_artist_test );

my $utf8_artist_list = $utf8_artist_test->artist_list();
ok( $utf8_artist_list );

my $search_multi_inc = $ws->search({ MBID => '070d193a-845c-479f-980e-bef15710653e', INC => 'aliases artist-rels' });
ok( $search_multi_inc, 'get INC multi params' );
