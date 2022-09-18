use strict;
use Test::More;

use Data::Dumper;
use Mojo::IOLoop;
use Syntax::Keyword::Try;

use WebService::MusicBrainz;

#
## Ported from Area.t, but this is all boilerplate and should likely break out into it's own idea
my $ws = WebService::MusicBrainz->new(
  throttle => 1.65,
);
ok($ws);

my $NODIE = 0;
my $WILLDIE = 1;
sub queue_request {
  my $expectDeath = shift;
  my $cb = shift;
  my $errcb = shift;
  my $prom;
  try {
    $prom = $ws->search_p(@_);
    ok(ref($prom) eq 'Mojo::Promise', "Search_p returns a promise");
  } catch {
    my $expected = ($expectDeath) ? "(expected)" : "(UNexpected)";
    ok($expectDeath, "Search_p died ($expected): $@");
    return;
  }
    
  $prom->then(sub {
    $cb->(shift);
    return;
  })->catch(sub {
    $errcb->($_[0]);
    warn "Detected error; $_[0]\n" . Dumper(\@_);
    return;
  });
}

my $errcheck = sub {
  ok(0, "Detected an error: $_[0]");
};
my $check = sub {
  my $res = shift;
  ok($res->{type} eq 'City');
  ok($res->{name} eq 'Nashville');
  ok($res->{'sort-name'} eq 'Nashville');
};
queue_request($NODIE, $check, $errcheck, area => { mbid => '044208de-d843-4523-bd49-0957044e05ae' });

$check = sub {
  my $res = shift;
  ok($res->{count} == 2);
  ok($res->{areas}->[0]->{type} eq 'City');
  ok($res->{areas}->[1]->{type} eq 'City');
};
queue_request($NODIE, $check, $errcheck, area => { area => 'cincinnati' });

$check = sub {
  my $res = shift;
  ok($res->{count} == 1);
  ok($res->{areas}->[0]->{name} eq 'Ohio');
};
queue_request($NODIE, $check, $errcheck, area => { iso => 'US-OH' });

$check = sub {
  ok(0,"Should not get a success here");
  warn Dumper(\@_);
};
queue_request($WILLDIE, $check, sub {
  ok(0,"This should have detected an error, but not at this stage: ($_[0])");
  warn Dumper(\@_);
}, area => { something => '99999' });

$check = sub {
  my $res = shift;
  ok($res->find('name')->first->text eq 'California');
  ok($res->at('area')->attr('ns2:score') == 100);

  Mojo::IOLoop->stop();
};
queue_request($NODIE, $check, $errcheck, area => { iso => 'US-CA', fmt => 'xml' });

Mojo::IOLoop->singleton->start;
done_testing();
