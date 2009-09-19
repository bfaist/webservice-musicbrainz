# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
BEGIN { use_ok('WebService::MusicBrainz::Release') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $sleep_duration = 2;

my $ws = WebService::MusicBrainz::Release->new();
ok( $ws, 'create WebService::MusicBrainz::Release object' );

my $wsde = WebService::MusicBrainz::Release->new(HOST => 'de.musicbrainz.org');
my $wsde_query = $wsde->query();

ok( $wsde_query->{_baseurl} =~ m/de\.musicbrainz\.org/, 'create WebService::MusicBrainz::Release object/altername host' );

my $ws = WebService::MusicBrainz::Release->new();

my $rel_title = $ws->search({ TITLE => 'Van Halen' });
ok($rel_title, 'release by title');
my $rel_title_rel_list = $rel_title->release_list();
ok($rel_title_rel_list, 'release by title RELEASE LIST');
ok($rel_title_rel_list->count() > 5, 'release by title rel list COUNT');
foreach my $release (@{ $rel_title_rel_list->releases() }) {
    if($release->id() eq "0d5f0dc2-b597-4b6c-9a6f-49b70b8e23b6") {
        ok($release->type() eq "Album Official", 'release by title rel TYPE');
        ok($release->score() > 90, 'release by title rel SCORE');
        ok($release->title() eq "Van Halen", 'release by title rel TITLE');
        ok($release->text_rep_language() eq "ENG", 'release by title rel LANG');
        ok($release->text_rep_script() eq "Latn", 'release by title rel SCRIPT');
        ok($release->asin() eq "B00004Y6O9", 'release by title rel ASIN');
        ok($release->artist()->name() eq "Van Halen", 'release by title rel artist NAME');
        ok($release->disc_list()->count() > 10, 'release by title rel disc list COUNT');
        ok($release->track_list()->count() > 10, 'release by title rel track list COUNT');
        foreach my $event (@{ $release->release_event_list()->events() }) {
        }
    }
}

sleep($sleep_duration);

my $rel_discid = $ws->search({ DISCID => 'Qb6ACLJhzNM46cXKVZSh3qMOv6A-' });
ok( $rel_discid, 'release by discid');
my $rel_discid_release = $rel_discid->release();
ok( $rel_discid_release, 'release by disc RELEASE');
ok( $rel_discid_release->title() eq "Van Halen", 'release by disc TITLE');
ok( $rel_discid_release->text_rep_language() eq "ENG", 'release by disc LANG');
ok( $rel_discid_release->text_rep_script() eq "Latn", 'release by disc SCRIPT');
ok( $rel_discid_release->artist()->name() eq "Van Halen", 'release by disc artist NAME');
ok( $rel_discid_release->artist()->sort_name() eq "Van Halen", 'release by disc artist SORT NAME');
foreach my $event (@{ $rel_discid_release->release_event_list()->events() }) {
    if($event->catalog_number() eq "9362-47737-2") {
       ok($event->date() eq "2000", 'rel disc rel eventlist event DATE');
       ok($event->country() eq "US", 'rel disc rel eventlist event COUNTRY');
       ok($event->barcode() eq "093624773726", 'rel disc rel eventlist event BARCODE');
       last;
    }
}
ok( $rel_discid_release->disc_list()->count() > 10, 'release by disc disc list COUNT');

foreach my $track (@{ $rel_discid_release->track_list()->tracks() }) {
    if($track->id() eq "619f18ad-b7c8-4b0e-826e-585de75b33f8") {
        ok($track->title() eq "Eruption", 'release by disc track list track TITLE');
        ok($track->duration() eq "102626", 'release by disc track list track DURATION');
    }
}

my $rel_artist_response = $ws->search({ ARTIST => 'Van Halen' });
ok( $rel_artist_response, 'rel by artist');
foreach my $release (@{ $rel_artist_response->release_list()->releases() }) {
    if($release->id() eq "cac41921-bd04-4ceb-b41c-ca9eb495c0f6") {
        ok( $release->type() eq "Album Official", 'rel by artist release TYPE');
        ok( $release->score() > 90, 'rel by artist release SCORE');
        ok( $release->title() eq "5150", 'rel by artist release TITLE');
        ok( $release->text_rep_language() eq "ENG", 'rel by artist release LANG');
        ok( $release->text_rep_script() eq "Latn", 'rel by artist release SCRIPT');
        ok( $release->asin() eq "B000002L99", 'rel by artist release ASIN');
        ok( $release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel by artist release ARTIST');
        ok( $release->artist()->name() eq "Van Halen", 'rel by artist release artist NAME');
        ok( $release->disc_list()->count() > 4, 'rel by artist release artist disc list COUNT');
        ok( $release->track_list()->count() > 8, 'rel by artist release artist track list COUNT');
        last;
    }
}

done_testing();
