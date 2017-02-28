use Test::More;

use WebService::MusicBrainz;
use Data::Dumper;

my $ws = WebService::MusicBrainz->new();
ok($ws);

# JSON TESTS
my $s1_res = $ws->search(area => { mbid => '044208de-d843-4523-bd49-0957044e05ae' });
ok($s1_res->{type} eq 'City');
ok($s1_res->{name} eq 'Nashville');
ok($s1_res->{'sort-name'} eq 'Nashville');

done_testing();
