use strict;
use Test::More;

use Mojo::IOLoop;
use WebService::MusicBrainz;

sub fail_if_mb_busy {
   my $res = shift;
   if(exists $res->{error}) {
     ok(0, "We got an error so we are presuming the cache is not working: " . $res->{error});
     exit(0);
   }
}

# In practice, the usage of cache like this will remove any upper level control of this
# cache. Thankfully, this is just a test. :)
my $ws = WebService::MusicBrainz->new( cache => {}, throttle => 1.1 );
ok($ws);

# Blocking mode
foreach my $k (0..10) {
  my $res = $ws->search(area => { mbid => '044208de-d843-4523-bd49-0957044e05ae' });
  fail_if_mb_busy($res);
  ok($res->{type} eq 'City');
  ok($res->{name} eq 'Nashville');
  ok($res->{'sort-name'} eq 'Nashville');
}

# Non-blocking mode, but this should never put a request out because it's in the
# cache.
foreach my $k (0..10) {
  $ws->search_p(area => { mbid => '044208de-d843-4523-bd49-0957044e05ae' })->then(sub {
    my $res = shift;
    ok($res->{type} eq 'City');
    ok($res->{name} eq 'Nashville');
    ok($res->{'sort-name'} eq 'Nashville');
    Mojo::IOLoop->stop() if ($k == 10);
  })->catch(sub {
    ok(0, "Some error occurred in non-blocking request: $_[0]");
  });
}

Mojo::IOLoop->start;
done_testing();
