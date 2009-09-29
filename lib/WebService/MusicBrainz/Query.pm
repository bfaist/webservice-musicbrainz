package WebService::MusicBrainz::Query;

use strict;
use LWP::UserAgent;
use URI;
use URI::Escape;
use WebService::MusicBrainz::Response;

our $VERSION = '0.22';

=head1 NAME

WebService::MusicBrainz::Query

=head1 SYNOPSIS

=head1 ABSTRACT

WebService::MusicBrainz - Interface with the MusicBrainz web service.

=head1 DESCRIPTION

This module's relationship with WebService::MusicBrainz::Artist,
WebService::MusicBrainz::Release, and WebService::MusicBrainz::Track is a "has a" relationship.  This module will not be 
instantiated by any client but will only be used internally within the Artist, Release, or Track classes.

=head1 METHODS

=head2 new()

This method is the constructor and it will call for initialization.  An optional HOST parameter can be passed to select a different mirrored server.

=cut

sub new {
   my $class = shift;
   my $self = {};

   bless $self, $class;

   $self->_init(@_);

   return $self;
}

sub _init {
   my $self = shift;
   my %params = @_;

   my $web_service_uri = URI->new();

   my $web_service_uri_scheme = "http";
   my $web_service_host = $params{HOST} || 'musicbrainz.org';
   my $web_service_namespace = 'ws';
   my $web_service_version = '1';

   $web_service_uri->scheme($web_service_uri_scheme);
   $web_service_uri->host($web_service_host);
   $web_service_uri->path("$web_service_namespace/$web_service_version/");

   $self->{_baseurl} = $web_service_uri->as_string();
}

=head2 set_url_params()

Define a list of valid URL query parameters.

=cut

sub set_url_params {
   my $self = shift;
   my @params = @_;

   foreach my $p (@params) {
      push @{ $self->{_valid_url_params} }, lc($p);
   }
}

=head2 set_inc_params()

Define a list of valid arguments for the "inc" URL query parameter.

=cut

sub set_inc_params {
   my $self = shift;
   my @params = @_;

   foreach my $p (@params) {
      push @{ $self->{_valid_inc_params} }, lc($p);
   }
}

sub _url {
   my $self = shift;
   my $class = shift;
   my $params = shift;

   $self->_validate_params($params);

   my $url =  $self->{_baseurl} . $class . '/';
   $url .= $params->{MBID} if $params->{MBID};
   $url .= '?type=xml';

   foreach my $key (keys %{ $params }) {
      $url .= '&' . lc($key) . '=' . $params->{$key} unless lc($key) eq "mbid";
   }
      
   # warn "URL: $url\n";

   return $url;
}

=head2 get()

Perform the URL request (GET) and if success, then return a WebService::MusicBrainz::Response object.  Otherwise die.

=cut

sub get {
   my $self = shift;
   my $class = shift;
   my $params = shift;

   my $url = $self->_url($class, $params);
   
   my $ua = LWP::UserAgent->new();
   $ua->env_proxy();

   $ua->agent("WebService::MusicBrainz/$VERSION");

   my $response = $ua->get($url);

   if($response->code() eq "200") {
       my $r = WebService::MusicBrainz::Response->new( XML => $response->content );

       return $r;
   }

   die "URL (", $url, ") Request Failed - Code: ", $response->code(), " Error: ", $response->message(), "\n";
}

sub _validate_params {
   my $self = shift;
   my $params = shift;

   foreach my $key (sort keys %{ $params }) {
      my $valid = 0;

      my @new_terms;
      foreach my $term (split /[\s\+,]/, $params->{$key}) {
          push @new_terms, URI::Escape::uri_escape_utf8($term);
      }

      $params->{$key} = join '+', @new_terms;

      if(lc($key) eq "inc") {
         foreach my $iparam (split /[\s,]/, $params->{INC}) {
              foreach my $vparam (@{ $self->{_valid_inc_params} }) {
                  if((lc($iparam) eq lc($vparam)) || ($iparam =~ m/^$vparam/)) {
                      $valid = 1;
                      last;
                  }
              }
          }
      } else {
          foreach my $vparam (@{ $self->{_valid_url_params} }) {
             if(lc($key) eq lc($vparam)) {
                $valid = 1;
                last;
             }
         }
      }

      if($valid == 0) {
         die "Invalid parameter : $key";
      }
   }

   return $params;
}

=head1 AUTHOR

=over 4

=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2009 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
