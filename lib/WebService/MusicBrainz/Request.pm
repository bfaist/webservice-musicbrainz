package WebService::MusicBrainz::Request;

use Mojo::Base -base;
use Mojo::IOLoop;
use Mojo::Promise;
use Mojo::UserAgent;
use Mojo::URL;
use Mojo::Util qw/dumper/;
use Time::HiRes qw(gettimeofday tv_interval sleep);

has url_base => 'https://musicbrainz.org/ws/2';
has ua => sub { Mojo::UserAgent->new() };
has 'format' => 'json';
has 'search_resource';
has 'mbid';
has 'discid';
has 'inc' => sub { [] };
has 'query_params';
has offset => 0;
has debug => sub { $ENV{MUSICBRAINZ_DEBUG} || 0 };;

# New features will not be used unless they are explicitly defined
has 'cache';
has 'throttle';
has 'uaid';
has 'uaemail';
has 'v';
has '_lastrequest' => sub { [0,0] };

our $VERSION = '1.0';

binmode STDOUT, ":encoding(UTF-8)";

sub make_url {
    my $self = shift;

    my @url_parts;

    push @url_parts, $self->url_base();
    push @url_parts, $self->search_resource();
    push @url_parts, $self->mbid() if $self->mbid;
    push @url_parts, $self->discid() if $self->discid;

    my $url_str = join '/', @url_parts;

    $url_str .= '?fmt=' . $self->format;

    if(scalar(@{ $self->inc }) > 0) {
        my $inc_query = join '+', @{ $self->inc }; 

        $url_str .= '&inc=' . $inc_query;
    }

    my @extra_params;

    foreach my $key (keys %{ $self->query_params }) {
        push @extra_params, $key . ':"' . $self->query_params->{$key} . '"';
    }

    if(scalar(@extra_params) > 0) {
        my $extra_param_str = join ' AND ', @extra_params;

        $url_str .= '&query=' . $extra_param_str; 
    }

    $url_str .= '&offset=' . $self->offset();

    print "REQUEST URL: $url_str\n" if $self->debug();

    my $url = Mojo::URL->new($url_str);

    return $url;
}

sub _ua_identify {
    my $self = shift;

    $self->ua->transactor->name("WebService::MusicBrainz/" . $self->v . ' { ' . $self->uaemail . '}')
       if (defined($self->uaemail) && length($self->uaemail) > 0);

    $self->ua->transactor->name($self->uaid) if (defined($self->uaid) && length($self->uaid) > 0);

    return;
}

sub _format_result {
  my ($self, $get_result) = (shift, shift);

  my $result_formatted;
  if($self->format eq 'json') {
    $result_formatted = $get_result->json;
    print "JSON RESULT: ", dumper($result_formatted) if $self->debug;
  } elsif($self->format eq 'xml') {
    $result_formatted = $get_result->dom;
    print "XML RESULT: ", $result_formatted->to_string, "\n" if $self->debug;
  } else {
    warn "Unsupported format type : $self->format";
  }
  return $result_formatted;
}

sub result {
    my $self = shift;

    $self->_ua_identify();

    my $request_url = $self->make_url();

    my $cachehit = (ref($self->cache) eq 'HASH') ? $self->cache->{$request_url} : undef;
    return $cachehit if (defined($cachehit));

    if (defined($self->throttle)) {
      warn "Throttle rate of '" . $self->throttle . "' is too low, this risks getting access blocked\n"
        if ($self->throttle < 1.0) ;

      my $reqrate = tv_interval($self->_lastrequest);
      sleep( $self->throttle - $reqrate + 0.1) if ($self->_lastrequest->[0] != 0 && $reqrate < $self->throttle);
    }

    my $get_result = $self->ua->get($request_url => { 'Accept-Encoding' => 'application/json' })->result;
    $self->_lastrequest([ gettimeofday ]);

    $self->cache->{$request_url} = $get_result if (ref($self->cache) eq 'HASH');

    return $self->_format_result($get_result);
}

sub result_p {
    my $self = shift;

    $self->_ua_identify();

    my $request_url = $self->make_url();
    my $cachehit = (ref($self->cache) eq 'HASH') ? $self->cache->{$request_url} : undef;
    return Mojo::Promise->resolve($cachehit) if (defined($cachehit));

    my $p = Mojo::Promise->new;
    my $make_promise = sub {
      return $self->ua->get_p($request_url => { 'Accept-Encoding' => 'application/json' });
    };
    my $resolve_promise = sub {
      my $tx = shift;
      my $result = $self->_format_result($tx->result);
      $self->cache->{$request_url} = $result if (ref($self->cache) eq 'HASH');
      $p->resolve($result);
      return;
    };
    my $reject_promise = sub { $p->reject(@_);return; };
     
    if (defined($self->throttle)) {
      warn "Throttle rate of '" . $self->throttle . "' is too low, this risks getting access blocked\n"
        if ($self->throttle < 1.0) ;

      my $reqrate = tv_interval($self->_lastrequest);
      if ($self->_lastrequest->[0] != 0 && $reqrate < $self->throttle) {
        my $runat = $self->throttle - $reqrate + 0.1;

        Mojo::IOLoop->timer( $runat => sub {
          $make_promise->()
          ->then($resolve_promise)
          ->catch($reject_promise);
        });
        return $p;
      }  
    }

    $make_promise->()
    ->then($resolve_promise)
    ->catch($reject_promise);

    return $p;
}

=head1 NAME

WebService::MusicBrainz::Request

=head1 SYNOPSIS

=head1 ABSTRACT

WebService::MusicBrainz::Request - Handle queries using the MusicBrainz WebService API version 2

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

=over 4

=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2017 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 SEE ALSO

https://wiki.musicbrainz.org/XMLWebService

=cut

1;
