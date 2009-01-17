# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
BEGIN { use_ok('WebService::MusicBrainz') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $artist_ws = WebService::MusicBrainz->new_artist();
ok( $artist_ws );

my $track_ws = WebService::MusicBrainz->new_track();
ok( $track_ws );

my $release_ws = WebService::MusicBrainz->new_release();
ok( $release_ws );
