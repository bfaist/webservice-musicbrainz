# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
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
        my $last_date = "0000-00-00";
        my $sorted = 1;
        foreach my $event (@{ $release->release_event_list()->events() }) {
            if($last_date le $event->date()) {
                $sorted = 1;
            } else {
                $sorted = 0;
                last;
            }
            $last_date = $event->date();
        }
        ok($sorted == 1,'release by title sorted release events');
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
    if($event->catalog_number() && $event->catalog_number() eq "9362-47737-2") {
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

sleep($sleep_duration);

my $rel_artistid_response = $ws->search({ ARTISTID => 'b665b768-0d83-4363-950c-31ed39317c15' });
ok( $rel_artistid_response, 'rel by artistid');
foreach my $release (@{ $rel_artistid_response->release_list()->releases() }) {
    if($release->id() eq "cac41921-bd04-4ceb-b41c-ca9eb495c0f6") {
        ok( $release->type() eq "Album Official", 'rel by artistid release TYPE');
        ok( $release->score() > 90, 'rel by artistid release SCORE');
        ok( $release->title() eq "5150", 'rel by artistid release TITLE');
        ok( $release->text_rep_language() eq "ENG", 'rel by artistid release LANG');
        ok( $release->text_rep_script() eq "Latn", 'rel by artistid release SCRIPT');
        ok( $release->asin() eq "B000002L99", 'rel by artistid release ASIN');
        ok( $release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel by artistid release ARTIST');
        ok( $release->artist()->name() eq "Van Halen", 'rel by artistid release artistid NAME');
        ok( $release->disc_list()->count() > 4, 'rel by artistid release artistid disc list COUNT');
        ok( $release->track_list()->count() > 8, 'rel by artistid release artistid track list COUNT');
        last;
    }
}

my $rel_reltypes_response = $ws->search({ ARTIST => 'Van Halen', RELEASETYPES => 'Bootleg' });
ok( $rel_reltypes_response, 'rel by reltyppes');
foreach my $release (@{ $rel_reltypes_response->release_list()->releases() }) {
    if($release->id() eq "3ae1eae2-c6f2-4c08-9805-ccfcdc7d2a4b") {
        ok($release->score() > 90, 'rel by reltypes SCORE');
        ok($release->type() eq "Live Bootleg", 'rel by reltypes TYPE');
        ok($release->title() eq "Secret Gig", 'rel by reltypes TITLE');
        ok( $release->text_rep_language() eq "ENG", 'rel by reltypes release LANG');
        ok( $release->text_rep_script() eq "Latn", 'rel by reltypes release SCRIPT');
        ok( $release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel by reltypes release ARTIST');
        ok( $release->artist()->name() eq "Van Halen", 'rel by reltypes release artistid NAME');
        ok( $release->disc_list()->count() > 0, 'rel by reltypes disc list COUNT');
        ok( $release->track_list()->count() > 3, 'rel by reltypes track list COUNT');
        last;
    }
}

sleep($sleep_duration);

my $rel_count_response = $ws->search({ ARTIST => 'Van Halen', COUNT => 10 });
ok( $rel_count_response, 'rel by count');
foreach my $release (@{ $rel_count_response->release_list()->releases() }) {
    if($release->id() eq "006b0c0e-2e35-49a4-9c2f-68770c6c1bde") {
        ok($release->score() > 90, 'rel by count SCORE');
        ok($release->type() eq "Album Official", 'rel by count TYPE');
        ok($release->title() eq "OU812", 'rel by count TITLE');
        ok( $release->text_rep_language() eq "ENG", 'rel by count release LANG');
        ok( $release->text_rep_script() eq "Latn", 'rel by count release SCRIPT');
        ok( $release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel by count release ARTIST');
        ok( $release->artist()->name() eq "Van Halen", 'rel by count release artistid NAME');
        ok( $release->disc_list()->count() > 2, 'rel by count disc list COUNT');
        ok( $release->track_list()->count() == 10, 'rel by count track list COUNT');
        last;
    }
}

my $rel_date_response = $ws->search({ ARTIST => 'Van Halen', DATE => '1980' });
ok( $rel_date_response, 'rel by date');
foreach my $release (@{ $rel_date_response->release_list()->releases() }) {
    if($release->id() eq "71ee7c4a-8da9-438d-a344-7626b91005dc") {
        ok($release->score() > 90, 'rel by date SCORE');
        ok($release->type() eq "Album Official", 'rel by date TYPE');
        ok($release->title() eq "Women and Children First", 'rel by date TITLE');
        ok( $release->text_rep_language() eq "ENG", 'rel by date release LANG');
        ok( $release->text_rep_script() eq "Latn", 'rel by date release SCRIPT');
        ok( $release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel by date release ARTIST');
        ok( $release->artist()->name() eq "Van Halen", 'rel by date release artistid NAME');
        ok( $release->disc_list()->count() > 5, 'rel by date disc list COUNT');
        ok( $release->track_list()->count() > 8, 'rel by date track list COUNT');
        foreach my $event (@{ $release->release_event_list()->events() }) {
            if($event->label() && $event->label() eq "Warner Music UK") {
                ok( $event->country() eq "GB", 'rel by date event COUNTRY');
                ok( $event->date() eq "1980", 'rel by date event DATE');
                last;
            }
        }
        last;
    }
}

sleep($sleep_duration);

my $rel_asin_response = $ws->search({ ARTIST => 'Van Halen', ASIN => "B000002LEM" });
ok( $rel_asin_response, 'rel by asin');
foreach my $release (@{ $rel_asin_response->release_list()->releases() }) {
    if($release->id() eq "006b0c0e-2e35-49a4-9c2f-68770c6c1bde") {
        ok($release->score() > 90, 'rel by asin SCORE');
        ok($release->type() eq "Album Official", 'rel by asin TYPE');
        ok($release->title() eq "OU812", 'rel by asin TITLE');
        ok($release->asin() eq "B000002LEM", 'rel by asin ASIN');
        ok( $release->text_rep_language() eq "ENG", 'rel by asin release LANG');
        ok( $release->text_rep_script() eq "Latn", 'rel by asin release SCRIPT');
        ok( $release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel by asin release ARTIST');
        ok( $release->artist()->name() eq "Van Halen", 'rel by asin release artistid NAME');
        ok( $release->disc_list()->count() > 2, 'rel by asin disc list COUNT');
        ok( $release->track_list()->count() == 10, 'rel by asin track list COUNT');
        last;
    }
}

# TODO:  Not working.  MB bug?
# my $rel_lang_response = $ws->search({ ARTIST => 'Van Halen', LANG => "ENG" });
# ok( $rel_lang_response, 'rel by lang');
# foreach my $release (@{ $rel_lang_response->release_list()->releases() }) {
#     if($release->id() eq "006b0c0e-2e35-49a4-9c2f-68770c6c1bde") {
#         ok($release->score() > 90, 'rel by lang SCORE');
#         ok($release->type() eq "Album Official", 'rel by lang TYPE');
#         ok($release->title() eq "OU812", 'rel by lang TITLE');
#         ok($release->asin() eq "B000002LEM", 'rel by lang ASIN');
#         ok( $release->text_rep_language() eq "ENG", 'rel by lang release LANG');
#         ok( $release->text_rep_script() eq "Latn", 'rel by lang release SCRIPT');
#         ok( $release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel by lang release ARTIST');
#         ok( $release->artist()->name() eq "Van Halen", 'rel by lang release artistid NAME');
#         ok( $release->disc_list()->count() > 2, 'rel by lang disc list COUNT');
#         ok( $release->track_list()->count() == 10, 'rel by lang track list COUNT');
#         last;
#     }
# }
# 
# sleep($sleep_duration);
# 
# TODO:  Not working.  MB bug?
# my $rel_script_response = $ws->search({ ARTIST => 'Van Halen', SCRIPT => "Latn" });
# ok( $rel_script_response, 'rel by script');
# foreach my $release (@{ $rel_script_response->release_list()->releases() }) {
#     if($release->id() eq "006b0c0e-2e35-49a4-9c2f-68770c6c1bde") {
#         ok($release->score() > 90, 'rel by script SCORE');
#         ok($release->type() eq "Album Official", 'rel by script TYPE');
#         ok($release->title() eq "OU812", 'rel by script TITLE');
#         ok($release->script() eq "B000002LEM", 'rel by script ASIN');
#         ok( $release->text_rep_scriptuage() eq "ENG", 'rel by script release LANG');
#         ok( $release->text_rep_script() eq "Latn", 'rel by script release SCRIPT');
#         ok( $release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel by script release ARTIST');
#         ok( $release->artist()->name() eq "Van Halen", 'rel by script release artistid NAME');
#         ok( $release->disc_list()->count() > 2, 'rel by script disc list COUNT');
#         ok( $release->track_list()->count() == 10, 'rel by script track list COUNT');
#         last;
#     }
# }

my $rel_limit_response = $ws->search({ ARTIST => 'Van Halen', LIMIT => "40" });
ok( $rel_limit_response, 'rel by limit');
ok( scalar(@{ $rel_limit_response->release_list()->releases() }) == 40, 'release limit');

my $rel_mbid_artist_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'artist' });
ok( $rel_mbid_artist_response, 'rel mbid inc artist');
my $rel_mbid_artist_release = $rel_mbid_artist_response->release();
ok( $rel_mbid_artist_release, 'rel mbid inc artist RELEASE');
ok( $rel_mbid_artist_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc artist release ID');
ok( $rel_mbid_artist_release->type() eq "Album Official", 'rel mbid inc artist release TYPE');
ok( $rel_mbid_artist_release->title() eq "1984", 'rel mbid inc artist release TITLE');
ok( $rel_mbid_artist_release->text_rep_language() eq "ENG", 'rel mbid inc artist release LANG');
ok( $rel_mbid_artist_release->text_rep_script() eq "Latn", 'rel mbid inc artist release SCRIPT');
ok( $rel_mbid_artist_release->artist()->id() eq "b665b768-0d83-4363-950c-31ed39317c15", 'rel mbid inc artist release artist ID');
ok( $rel_mbid_artist_release->artist()->type() eq "Group", 'rel mbid inc artist release artist TYPE');
ok( $rel_mbid_artist_release->artist()->name() eq "Van Halen", 'rel mbid inc artist release artist NAME');
ok( $rel_mbid_artist_release->artist()->sort_name() eq "Van Halen", 'rel mbid inc artist release artist SORT NAME');

sleep($sleep_duration);

my $rel_mbid_counts_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'counts' });
ok( $rel_mbid_counts_response, 'rel mbid inc counts');
my $rel_mbid_counts_release = $rel_mbid_counts_response->release();
ok( $rel_mbid_counts_release, 'rel mbid inc counts RELEASE');
ok( $rel_mbid_counts_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc counts release ID');
ok( $rel_mbid_counts_release->type() eq "Album Official", 'rel mbid inc counts release TYPE');
ok( $rel_mbid_counts_release->title() eq "1984", 'rel mbid inc counts release TITLE');
ok( $rel_mbid_counts_release->text_rep_language() eq "ENG", 'rel mbid inc counts release LANG');
ok( $rel_mbid_counts_release->text_rep_script() eq "Latn", 'rel mbid inc counts release SCRIPT');
ok( $rel_mbid_counts_release->asin() eq "B00004Y6O3", 'rel mbid inc counts release ASIN');
ok( $rel_mbid_counts_release->release_event_list()->count() > 1 , 'rel mbid inc counts release release_info_list COUNT');
ok( $rel_mbid_counts_release->disc_list()->count() > 7, 'rel mbid inc counts release disc_list COUNT');

my $rel_mbid_events_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'release-events' });
ok( $rel_mbid_events_response, 'rel mbid inc events');
my $rel_mbid_events_release = $rel_mbid_events_response->release();
ok( $rel_mbid_events_release, 'rel mbid inc events RELEASE');
ok( $rel_mbid_events_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc events release ID');
ok( $rel_mbid_events_release->type() eq "Album Official", 'rel mbid inc events release TYPE');
ok( $rel_mbid_events_release->title() eq "1984", 'rel mbid inc events release TITLE');
ok( $rel_mbid_events_release->text_rep_language() eq "ENG", 'rel mbid inc events release LANG');
ok( $rel_mbid_events_release->text_rep_script() eq "Latn", 'rel mbid inc events release SCRIPT');
ok( $rel_mbid_events_release->asin() eq "B00004Y6O3", 'rel mbid inc events release ASIN');
foreach my $event (@{ $rel_mbid_events_release->release_event_list()->events() }) {
   if($event->barcode() eq "075992398527") {
      ok( $event->date() eq "1984-01-09", 'rel mbid inc events rel_event_list event DATE');
      ok( $event->country() eq "US", 'rel mbid inc events rel_event_list event COUNTRY');
      ok( $event->catalog_number() eq "9 23985-2", 'rel mbid inc events rel_event_list event CATALOG NUMBER');
      ok( $event->format() eq "CD", 'rel mbid inc events rel_event_list event FORMAT');
      last;
   }
}

sleep($sleep_duration);

my $rel_mbid_discs_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'discs' });
ok( $rel_mbid_discs_response, 'rel mbid inc discs');
my $rel_mbid_discs_release = $rel_mbid_discs_response->release();
ok( $rel_mbid_discs_release, 'rel mbid inc discs RELEASE');
ok( $rel_mbid_discs_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc discs release ID');
ok( $rel_mbid_discs_release->type() eq "Album Official", 'rel mbid inc discs release TYPE');
ok( $rel_mbid_discs_release->title() eq "1984", 'rel mbid inc discs release TITLE');
ok( $rel_mbid_discs_release->text_rep_language() eq "ENG", 'rel mbid inc discs release LANG');
ok( $rel_mbid_discs_release->text_rep_script() eq "Latn", 'rel mbid inc discs release SCRIPT');
ok( $rel_mbid_discs_release->asin() eq "B00004Y6O3", 'rel mbid inc discs release ASIN');
foreach my $disc (@{ $rel_mbid_discs_release->disc_list()->discs() }) {
   if($disc->id() eq "RYubBCKHdNeT.M51Xv6hUeCuUjY-") {
      ok( $disc->sectors() eq "150400", 'rel mbid inc discs SECTORS');
      last;
   }
}

my $rel_mbid_tracks_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'tracks' });
ok( $rel_mbid_tracks_response, 'rel mbid inc tracks');
my $rel_mbid_tracks_release = $rel_mbid_tracks_response->release();
ok( $rel_mbid_tracks_release, 'rel mbid inc tracks RELEASE');
ok( $rel_mbid_tracks_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc tracks release ID');
ok( $rel_mbid_tracks_release->type() eq "Album Official", 'rel mbid inc tracks release TYPE');
ok( $rel_mbid_tracks_release->title() eq "1984", 'rel mbid inc tracks release TITLE');
ok( $rel_mbid_tracks_release->text_rep_language() eq "ENG", 'rel mbid inc tracks release LANG');
ok( $rel_mbid_tracks_release->text_rep_script() eq "Latn", 'rel mbid inc tracks release SCRIPT');
ok( $rel_mbid_tracks_release->asin() eq "B00004Y6O3", 'rel mbid inc tracks release ASIN');
foreach my $track (@{ $rel_mbid_tracks_release->track_list()->tracks() }) {
   if($track->id() eq "77ee68a0-f28e-46ce-9751-2ec2c54943c6") {
      ok( $track->title() eq "Hot for Teacher", 'rel mbid inc tracks TITLE');
      ok( $track->duration() eq "284600", 'rel mbid inc tracks DURATION');
      last;
   }
}

sleep($sleep_duration);

my $rel_mbid_relgroups_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'release-groups' });
ok( $rel_mbid_relgroups_response, 'rel mbid inc relgroups');
my $rel_mbid_relgroups_release = $rel_mbid_relgroups_response->release();
ok( $rel_mbid_relgroups_release, 'rel mbid inc relgroups RELEASE');
ok( $rel_mbid_relgroups_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc relgroups release ID');
ok( $rel_mbid_relgroups_release->type() eq "Album Official", 'rel mbid inc relgroups release TYPE');
ok( $rel_mbid_relgroups_release->title() eq "1984", 'rel mbid inc relgroups release TITLE');
ok( $rel_mbid_relgroups_release->text_rep_language() eq "ENG", 'rel mbid inc relgroups release LANG');
ok( $rel_mbid_relgroups_release->text_rep_script() eq "Latn", 'rel mbid inc relgroups release SCRIPT');
ok( $rel_mbid_relgroups_release->asin() eq "B00004Y6O3", 'rel mbid inc relgroups release ASIN');
ok( $rel_mbid_relgroups_release->release_group()->id() eq "5846f0c9-fec3-3b9e-a77c-fbe9a7bdf0e7", 'rel mbid inc relgroups ID');
ok( $rel_mbid_relgroups_release->release_group()->type() eq "Album", 'rel mbid inc relgroups TYPE');
ok( $rel_mbid_relgroups_release->release_group()->title() eq "1984", 'rel mbid inc relgroups TITLE');


my $rel_mbid_artistrels_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'artist-rels' });
ok( $rel_mbid_artistrels_response, 'rel mbid inc artistrels');
my $rel_mbid_artistrels_release = $rel_mbid_artistrels_response->release();
ok( $rel_mbid_artistrels_release, 'rel mbid inc artistrels RELEASE');
ok( $rel_mbid_artistrels_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc artistrels release ID');
ok( $rel_mbid_artistrels_release->type() eq "Album Official", 'rel mbid inc artistrels release TYPE');
ok( $rel_mbid_artistrels_release->title() eq "1984", 'rel mbid inc artistrels release TITLE');
ok( $rel_mbid_artistrels_release->text_rep_language() eq "ENG", 'rel mbid inc artistrels release LANG');
ok( $rel_mbid_artistrels_release->text_rep_script() eq "Latn", 'rel mbid inc artistrels release SCRIPT');
ok( $rel_mbid_artistrels_release->asin() eq "B00004Y6O3", 'rel mbid inc artistrels release ASIN');
ok( $rel_mbid_artistrels_release->relation_list()->target_type() eq "Artist", 'rel mbid inc artistrels release rellist TARGETTYPE');
foreach my $relation (@{ $rel_mbid_artistrels_release->relation_list()->relations() }) {
   if($relation->target() eq "802d37d5-0aaa-492e-b366-99f75e5a196f") {
      ok( $relation->type() eq "Vocal", 'rel mbid inc artistrels release TYPE');
      ok( $relation->artist()->id() eq "802d37d5-0aaa-492e-b366-99f75e5a196f", 'rel mbid inc artistrels artist ID');
      ok( $relation->artist()->name() eq "David Lee Roth", 'rel mbid inc artistrels artist NAME');
      ok( $relation->artist()->sort_name() eq "Roth, David Lee", 'rel mbid inc artistrels artist SORTNAME');
      ok( $relation->artist()->life_span_begin() eq "1955-10-10", 'rel mbid inc artistrels artist BEGIN');
      last;
   }
}

sleep($sleep_duration);

# label-rels
# release-rels
# track-rels

my $rel_mbid_urlrels_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'url-rels' });
ok( $rel_mbid_urlrels_response, 'rel mbid inc urlrels');
my $rel_mbid_urlrels_release = $rel_mbid_urlrels_response->release();
ok( $rel_mbid_urlrels_release, 'rel mbid inc urlrels RELEASE');
ok( $rel_mbid_urlrels_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc urlrels release ID');
ok( $rel_mbid_urlrels_release->type() eq "Album Official", 'rel mbid inc urlrels release TYPE');
ok( $rel_mbid_urlrels_release->title() eq "1984", 'rel mbid inc urlrels release TITLE');
ok( $rel_mbid_urlrels_release->text_rep_language() eq "ENG", 'rel mbid inc urlrels release LANG');
ok( $rel_mbid_urlrels_release->text_rep_script() eq "Latn", 'rel mbid inc urlrels release SCRIPT');
ok( $rel_mbid_urlrels_release->asin() eq "B00004Y6O3", 'rel mbid inc urlrels release ASIN');
ok( $rel_mbid_urlrels_release->relation_list()->target_type() eq "Url", 'rel mbid inc urlrels release rellist TARGETTYPE');
foreach my $relation (@{ $rel_mbid_urlrels_release->relation_list()->relations() }) {
   if($relation->target() eq 'http://en.wikipedia.org/wiki/1984_%28Van_Halen_album%29') {
      ok( $relation->type() eq "Wikipedia", 'rel mbid inc urlrels release TYPE');
      last;
   }
}

# track-level-rels

my $rel_mbid_labels_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'release-events+labels' });
ok( $rel_mbid_labels_response, 'rel mbid inc labels');
my $rel_mbid_labels_release = $rel_mbid_labels_response->release();
ok( $rel_mbid_labels_release, 'rel mbid inc labels RELEASE');
ok( $rel_mbid_labels_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc labels release ID');
ok( $rel_mbid_labels_release->type() eq "Album Official", 'rel mbid inc labels release TYPE');
ok( $rel_mbid_labels_release->title() eq "1984", 'rel mbid inc labels release TITLE');
ok( $rel_mbid_labels_release->text_rep_language() eq "ENG", 'rel mbid inc labels release LANG');
ok( $rel_mbid_labels_release->text_rep_script() eq "Latn", 'rel mbid inc labels release SCRIPT');
ok( $rel_mbid_labels_release->asin() eq "B00004Y6O3", 'rel mbid inc labels release ASIN');
foreach my $event (@{ $rel_mbid_labels_release->release_event_list()->events() }) {
   if($event->barcode() eq '075992398527') {
      ok( $event->date() eq "1984-01-09", 'rel mbid inc labels release event DATE');
      ok( $event->country() eq "US", 'rel mbid inc labels release event COUNTRY');
      ok( $event->catalog_number() eq "9 23985-2", 'rel mbid inc labels release event CAT NUM');
      ok( $event->format() eq "CD", 'rel mbid inc labels release event FORMAT');
      ok( $event->label()->id() eq "c595c289-47ce-4fba-b999-b87503e8cb71", 'rel mbid inc labels release event label ID');
      ok( $event->label()->name() eq "Warner Bros. Records", 'rel mbid inc labels release event label NAME');
      last;
   }
}

sleep($sleep_duration);

my $rel_mbid_tags_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'tags' });
ok( $rel_mbid_tags_response, 'rel mbid inc tags');
my $rel_mbid_tags_release = $rel_mbid_tags_response->release();
ok( $rel_mbid_tags_release, 'rel mbid inc tags RELEASE');
ok( $rel_mbid_tags_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc tags release ID');
ok( $rel_mbid_tags_release->type() eq "Album Official", 'rel mbid inc tags release TYPE');
ok( $rel_mbid_tags_release->title() eq "1984", 'rel mbid inc tags release TITLE');
ok( $rel_mbid_tags_release->text_rep_language() eq "ENG", 'rel mbid inc tags release LANG');
ok( $rel_mbid_tags_release->text_rep_script() eq "Latn", 'rel mbid inc tags release SCRIPT');
ok( $rel_mbid_tags_release->asin() eq "B00004Y6O3", 'rel mbid inc tags release ASIN');
foreach my $tag (@{ $rel_mbid_tags_release->tag_list()->tags() }) {
     ok( $tag->count() > 0, 'rel mbid inc tags tag COUNT') if($tag->text() eq "hard rock");
     ok( $tag->count() > 0, 'rel mbid inc tags tag COUNT') if($tag->text() eq "rock");
     ok( $tag->count() > 0, 'rel mbid inc tags tag COUNT') if($tag->text() eq "1984");
}

my $rel_mbid_ratings_response = $ws->search({ MBID => 'ff565cd7-acf8-4dc0-9603-72d1b7ae284b', INC => 'ratings' });
ok( $rel_mbid_ratings_response, 'rel mbid inc ratings');
my $rel_mbid_ratings_release = $rel_mbid_ratings_response->release();
ok( $rel_mbid_ratings_release, 'rel mbid inc ratings RELEASE');
ok( $rel_mbid_ratings_release->id() eq "ff565cd7-acf8-4dc0-9603-72d1b7ae284b", 'rel mbid inc ratings release ID');
ok( $rel_mbid_ratings_release->type() eq "Album Official", 'rel mbid inc ratings release TYPE');
ok( $rel_mbid_ratings_release->title() eq "1984", 'rel mbid inc ratings release TITLE');
ok( $rel_mbid_ratings_release->text_rep_language() eq "ENG", 'rel mbid inc ratings release LANG');
ok( $rel_mbid_ratings_release->text_rep_script() eq "Latn", 'rel mbid inc ratings release SCRIPT');
ok( $rel_mbid_ratings_release->asin() eq "B00004Y6O3", 'rel mbid inc ratings release ASIN');
ok( $rel_mbid_ratings_release->rating()->votes_count() > 1, 'rel mbid inc ratings release rating VOTE COUNT');
ok( $rel_mbid_ratings_release->rating()->value() > 3, 'rel mbid inc ratings release rating TEXT');

# isrcs

done_testing();
