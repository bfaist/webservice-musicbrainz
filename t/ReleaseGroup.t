# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use Test::More;
BEGIN { use_ok('WebService::MusicBrainz::ReleaseGroup') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $sleep_duration = 2;

my $ws = WebService::MusicBrainz::ReleaseGroup->new();
ok( $ws, 'create WebService::MusicBrainz::ReleaseGroup object' );

my $wsde = WebService::MusicBrainz::ReleaseGroup->new(HOST => 'de.musicbrainz.org');
my $wsde_query = $wsde->query();
ok( $wsde_query->{_baseurl} =~ m/de\.musicbrainz\.org/, 'create WebService::MusicBrainz::ReleaseGroup object/altername host' );


sleep($sleep_duration);

done_testing();
