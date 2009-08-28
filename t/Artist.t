# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
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

my $mbid_response = $ws->search({ MBID => '4eca1aa0-c79f-481b-af8a-4a2d6c41aa5c' });
ok( $mbid_response, 'artist by MBID' );

my $mbid_artist = $mbid_response->artist();
ok( $mbid_artist, 'artist obj');
ok( $mbid_artist->name() eq "Miranda Lambert", 'artist name'); 
ok( $mbid_artist->sort_name() eq "Lambert, Miranda", 'artist sort_name'); 
ok( $mbid_artist->life_span_begin() eq "1983-11-10", 'artist life_span_begin'); 

my $name_response = $ws->search({ NAME => 'Pantera' });
ok( $name_response, 'artist by NAME' );
my $name_artist_list = $name_response->artist_list();
ok( $name_artist_list, 'artist list obj' );
ok( $name_artist_list->count() >= 3, 'artist list count' );
ok( $name_artist_list->offset() == 0, 'artist list offset' );
my $name_artist = $name_artist_list->artists()->[0];
ok( $name_artist, 'first artist' );
ok( $name_artist->id() eq "541f16f5-ad7a-428e-af89-9fa1b16d3c9c", 'first artist id' );
ok( $name_artist->name() eq "Pantera", 'first artist name' );
ok( $name_artist->sort_name() eq "Pantera", 'first artist sort-name' );
ok( $name_artist->type() eq "Group", 'first artist type' );
ok( $name_artist->score() eq "100", 'first artist score' );
ok( $name_artist->life_span_begin() eq "1982", 'first artist life-span-begin' );
ok( $name_artist->life_span_end() eq "2003", 'first artist life-span-end' );

sleep($sleep_duration);

my $name_limit_response = $ws->search({ NAME => 'Elvis', LIMIT => 3 });
ok( $name_limit_response, 'artist by NAME LIMIT' );
my $name_limit_artist_list = $name_limit_response->artist_list();
ok( $name_limit_artist_list, 'artist list by NAME LIMIT');
ok( $name_limit_artist_list->count() > 90, 'artist list count LIMIT');
my $artist_counter = 0;
foreach my $artist_node (@{ $name_limit_artist_list->artists() }) {
    $artist_counter++;
}
ok( $artist_counter == 3, 'artist limit check');

my $name_offset_response = $ws->search({ NAME => 'Elvis', OFFSET => 10 });
ok( $name_offset_response, 'artist by NAME OFFSET' );
my $name_offset_artist_list = $name_offset_response->artist_list();
ok( $name_offset_artist_list, 'artist list OFFSET');
ok( $name_offset_artist_list->count() > 90, 'artist offset COUNT');
ok( $name_offset_artist_list->offset() == 10, 'artist offset OFFSET');

sleep($sleep_duration);

my $name_limit_offset_response = $ws->search({ NAME => 'Elvis', LIMIT => 5, OFFSET => 6 });
ok( $name_limit_offset_response, 'artist by NAME LIMIT OFFSET' );
my $name_limit_offset_artist_list = $name_limit_offset_response->artist_list();
ok( $name_limit_offset_artist_list, 'artist list LIMIT OFFSET' );
ok( $name_limit_offset_artist_list->offset() == 6, 'artist limit offset OFFSET');

my $mbid_aliases_response = $ws->search({ MBID => '070d193a-845c-479f-980e-bef15710653e', INC => 'aliases' });
ok( $mbid_aliases_response, 'artist by MBID ALIASES' );
my $mbid_aliases_artist = $mbid_aliases_response->artist();
ok( $mbid_aliases_artist, 'artist aliases');
ok( $mbid_aliases_artist->type() eq "Person", 'artist aliases TYPE');
ok( $mbid_aliases_artist->name() eq "Prince", 'artist aliases NAME');
ok( $mbid_aliases_artist->sort_name() eq "Prince", 'artist aliases SORT NAME');
ok( $mbid_aliases_artist->life_span_begin() eq "1958-06-07", 'artist aliases LIFE SPAN BEGIN');
my $mbid_aliases_alias_list = $mbid_aliases_artist->alias_list();
ok( $mbid_aliases_alias_list, 'artist aliases ALIAS LIST');
ok( scalar(@{ $mbid_aliases_alias_list->aliases() }) > 2, 'artist aliases ALIAS COUNT');

sleep($sleep_duration);

my $mbid_release_groups_response = $ws->search({ MBID => '4dca4bb2-23ba-4103-97e6-5810311db33a', INC => 'release-groups sa-Album' });
ok( $mbid_release_groups_response, 'artist by MBID RELEASE-GROUPS' );
my $mbid_rg_artist = $mbid_release_groups_response->artist();
ok( $mbid_rg_artist, 'artist release-groups');
my $mbid_rg_release_list = $mbid_rg_artist->release_list();
ok( $mbid_rg_release_list,'artist release-groups RELEASE LIST');
my $mbid_rg_release_group_list = $mbid_rg_artist->release_group_list();
ok( $mbid_rg_release_group_list, 'artist release-groups RELEASE GROUP LIST');
ok( scalar(@{ $mbid_rg_release_group_list->release_groups() }) > 1, 'artist release-groups RELEASE GROUPS');

my $mbid_artist_rels_response = $ws->search({ MBID => 'ae1b47d5-5128-431c-9d30-e08fd90e0767', INC => 'artist-rels' });
ok( $mbid_artist_rels_response, 'artist by MBID ARTIST-RELS' );
my $mbid_artist_rels_artist = $mbid_artist_rels_response->artist();
ok( $mbid_artist_rels_artist, 'artist artist-rels ARTIST');
ok( $mbid_artist_rels_artist->type() eq "Group", 'artist artist-rels GROUP');
ok( $mbid_artist_rels_artist->name() eq "Coheed and Cambria", 'artist artist-rels NAME');
ok( $mbid_artist_rels_artist->sort_name() eq "Coheed and Cambria", 'artist artist-rels SORT NAME');
my $mbid_artist_rels_list = $mbid_artist_rels_artist->relation_list();
ok( $mbid_artist_rels_list, 'artist artist-rels RELATION LIST');
ok( $mbid_artist_rels_list->target_type() eq "Artist",'artist artist-rels relation-list TARGET TYPE');
foreach my $relation (@{ $mbid_artist_rels_list->relations() }) {
    if($relation->target() eq "56c0c0ec-5973-4ce8-9fd8-ba7b46ce0a9e") {
        ok( $relation->type() eq "MemberOfBand",  'artist artist-rels relation TYPE');
        ok( $relation->direction() eq "backward",  'artist artist-rels relation DIRECTION');
        ok( $relation->begin() eq "1995",  'artist artist-rels relation BEGIN');
        my $ar = $relation->artist();
        ok( $ar, 'artist artist-rels relation ARTIST');
        ok( $ar->id() eq "56c0c0ec-5973-4ce8-9fd8-ba7b46ce0a9e", 'artist artist-rels relation artist ID');
        ok( $ar->type() eq "Person", 'artist artist-rels relation artist PERSON');
        ok( $ar->name() eq "Claudio Sanchez", 'artist artist-rels relation artist NAME');
        ok( $ar->sort_name() eq "Sanchez, Claudio", 'artist artist-rels relation artist SORT NAME');
        ok( $ar->life_span_begin() eq "1978-03-12", 'artist artist-rels relation artist LIFE SPAN BEGIN');
        last; 
    }
}

sleep($sleep_duration);

my $mbid_label_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'label-rels' });
ok( $mbid_label_rels_response, 'artist by MBID LABEL-RELS' );

my $mbid_release_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-rels' });
ok( $mbid_release_rels_response, 'artist by MBID RELEASE-RELS' );

sleep($sleep_duration);

my $mbid_track_rels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'track-rels' });
ok( $mbid_track_rels_response, 'artist by MBID TRACK-RELS' );

my $mbid_url_rels_response = $ws->search({ MBID => 'ae1b47d5-5128-431c-9d30-e08fd90e0767', INC => 'url-rels' });
ok( $mbid_url_rels_response, 'artist by MBID URL-RELS' );

sleep($sleep_duration);

my $mbid_tags_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'tags' });
ok( $mbid_tags_response, 'artist by MBID TAGS' );

my $mbid_ratings_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'ratings' });
ok( $mbid_ratings_response, 'artist by MBID RATINGS' );

# my $mbid_user_tags_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'user-tags' });
# ok( $mbid_user_tags_response, 'artist by MBID USERs-TAGS' );
# 
# my $mbid_user_ratings_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'user-ratings' });
# ok( $mbid_user_ratings_response, 'artist by MBID USER-RATINGS' );

sleep($sleep_duration);

my $mbid_counts_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'counts' });
ok( $mbid_counts_response, 'artist by MBID COUNTS' );

my $mbid_rel_events_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'release-events' });
ok( $mbid_rel_events_response, 'artist by MBID RELEASE-EVENTS' );

sleep($sleep_duration);

my $mbid_discs_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'discs' });
ok( $mbid_discs_response, 'artist by MBID DISCS' );

my $mbid_labels_response = $ws->search({ MBID => '65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab', INC => 'labels' });
ok( $mbid_labels_response, 'artist by MBID LABELS' );

sleep($sleep_duration);

done_testing();
