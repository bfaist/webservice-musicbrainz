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

done_testing();
