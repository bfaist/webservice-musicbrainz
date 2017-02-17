use Test::More;

use WebService::MusicBrainz;

my $ws = WebService::MusicBrainz->new();
ok($ws);

my $s1_res = $ws->search(artist => { mbid => '070d193a-845c-479f-980e-bef15710653e' });
ok($s1_res->{type} eq 'Person');
ok($s1_res->{'sort-name'} eq 'Prince');
ok($s1_res->{name} eq 'Prince');
ok($s1_res->{country} eq 'US');
ok($s1_res->{gender} eq 'Male');

my $s2_res = $ws->search(artist => { mbid => '070d193a-845c-479f-980e-bef15710653e', inc => 'releases' });
ok($s2_res->{type} eq 'Person');
ok(exists $s2_res->{releases});
ok($s2_res->{name} eq 'Prince');

my $s3_res = $ws->search(artist => { mbid => '070d193a-845c-479f-980e-bef15710653e', inc => ['releases','aliases'] });
ok(exists $s3_res->{releases});
ok(exists $s3_res->{aliases});

done_testing();
