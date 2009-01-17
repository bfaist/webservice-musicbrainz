# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WebService-MusicBrainz.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 20;
BEGIN { use_ok('WebService::MusicBrainz::Label') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# TEST SEARCH API

my $ws = WebService::MusicBrainz::Label->new();
ok( $ws );

my $name_search = $ws->search({ NAME => "Warner Music"});
ok( $name_search );

my $label_list = $name_search->label_list();
ok( $label_list );

my $labels = $label_list->labels();
ok( scalar(@$labels) > 1 );

my $first_label = $name_search->label();
ok($first_label);

ok($first_label->type() eq "Distributor");

my $mbid_search = $ws->search({ MBID => "c595c289-47ce-4fba-b999-b87503e8cb71" });
ok($mbid_search);

my $mbid_label = $mbid_search->label();
ok($mbid_label);

ok($mbid_label->life_span_begin() eq "1958-03-19");
ok($mbid_label->label_code() eq "392");
ok($mbid_label->country() eq "US");
ok($mbid_label->type() eq "OriginalProduction");

my $url_search = $ws->search({ MBID => "c595c289-47ce-4fba-b999-b87503e8cb71", INC => 'url-rels' });
ok($url_search);

my $url_label = $url_search->label();
ok($url_label);

my $url_rel_list = $url_label->relation_list();
ok($url_rel_list);

foreach my $url_rel (@{ $url_rel_list->relations() }) {
    ok($url_rel->type() =~ m/OfficialSite|Wikipedia/);
    ok($url_rel->target() =~ m/^http/);
}

# TEST RESPONSE OBJECT API
