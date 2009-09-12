package WebService::MusicBrainz::Response;

use strict;
use XML::LibXML;

our $VERSION = '0.22';

=head1 NAME

WebService::MusicBrainz::Response

=head1 SYNOPSIS

=head1 DESCRIPTION

This module will hide the details of the XML web service response and provide an API to query the XML data which has been returned.  This module is responsible for parsing the XML web service response and instantiating objects to provide access to the details of the response.

=head1 METHODS

=head2 new()

This method is the constructor and it will call for  initialization.

=cut

sub new {
   my $class = shift;
   my %params = @_;
   my $self = {};

   bless $self, $class;

   $self->{_xml} = $params{XML} || die "XML parameter required";

   $self->_load_xml();

   $self->_init();

   return $self;
}

sub _load_xml {
   my $self = shift;

   my $parser = XML::LibXML->new();

   my $document = $parser->parse_string($self->{_xml}) or die "Failure to parse XML";

   my $root = $document->getDocumentElement();

   my $xpc = XML::LibXML::XPathContext->new($root);

   $xpc->registerNs('mmd', $root->getAttribute('xmlns'));
   $xpc->registerNs('ext', $root->getAttribute('xmlns:ext')) if $root->getAttribute('xmlns:ext');

   $self->{_xmlobj} = $xpc;
   $self->{_xmlroot} = $root;

   return;
}

=head2 xpc()

=cut

sub xpc {
    my $self = shift;

    return $self->{_xmlobj};
}

=head2 as_xml()

This method returns the raw XML from the MusicBrainz web service response.

=cut

sub as_xml {
   my $self = shift;

   return $self->{_xmlroot}->toString();
}

sub _init {
   my $self = shift;

   my $xpc = $self->xpc() || return;

   my ($xArtist) = $xpc->findnodes('mmd:artist[1]');
   my ($xArtistList) = $xpc->findnodes('mmd:artist-list[1]');
   my ($xRelease) = $xpc->findnodes('mmd:release[1]');
   my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]');
   my ($xTrack) = $xpc->findnodes('mmd:track[1]');
   my ($xTrackList) = $xpc->findnodes('mmd:track-list[1]');
   my ($xLabel) = $xpc->findnodes('mmd:label[1]');
   my ($xLabelList) = $xpc->findnodes('mmd:label-list[1]');
   my ($xReleaseGroupList) = $xpc->findnodes('mmd:release-group-list[1]');

   require WebService::MusicBrainz::Response::Metadata;

   my $metadata = WebService::MusicBrainz::Response::Metadata->new();

   $metadata->generator( $xpc->find('@generator')->pop()->getValue() ) if $xpc->find('@generator');
   $metadata->created( $xpc->find('@created')->pop()->getValue() ) if $xpc->find('@created');
   $metadata->score( $xpc->find('@ext:score')->pop()->getValue() ) if $xpc->lookupNs('ext') && $xpc->find('@ext:score');
   $metadata->artist( $self->_create_artist( $xArtist ) ) if $xArtist;
   $metadata->artist_list( $self->_create_artist_list( $xArtistList ) ) if $xArtistList;
   $metadata->release( $self->_create_release( $xRelease ) ) if $xRelease;
   $metadata->release_list( $self->_create_release_list( $xReleaseList ) ) if $xReleaseList;
   $metadata->track( $self->_create_track( $xTrack ) ) if $xTrack;
   $metadata->track_list( $self->_create_track_list( $xTrackList ) ) if $xTrackList;
   $metadata->label( $self->_create_label( $xLabel ) ) if $xLabel;
   $metadata->label_list( $self->_create_label_list( $xLabelList ) ) if $xLabelList;
   $metadata->release_group_list( $self->_create_release_group_list( $xReleaseGroupList ) ) if $xReleaseGroupList;

   $self->{_metadata_cache} = $metadata;
}

=head2 generator()

This method will return an optional value of the generator.

=cut

sub generator {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->generator();
}

=head2 created()

This method will return an optional value of the created date.

=cut

sub created {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->created();
}

=head2 score()

This method will return an optional value of the relevance score.

=cut

sub score {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata->score();
}

=head2 metadata()

This method will return an Response::Metadata object.

=cut

sub metadata {
    my $self = shift;

    my $metadata = $self->{_metadata_cache};

    return $metadata;
}

=head2 artist()

This method will return an Response::Artist object.

=cut

sub artist {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $artist = $metadata->artist_list() ? $metadata->artist_list()->artists()->[0] : $metadata->artist();

   return $artist;
}

=head2 release()

This method will return an Reponse::Release object;.

=cut

sub release {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release = $metadata->release_list() ? $metadata->release_list()->releases()->[0] : $metadata->release();

   return $release;
}

=head2 track()

This method will return an Response::Track object.

=cut

sub track {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $track = $metadata->track_list() ? $metadata->track_list()->tracks()->[0] : $metadata->track();

   return $track;
}

=head2 label()

This method will return an Response::Label object.

=cut

sub label {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $label = $metadata->label_list() ? $metadata->label_list()->labels()->[0] : $metadata->label();

   return $label;
}

=head2 artist_list()

This method will return a reference to the Response::ArtistList object in a scalar context.  If in a array context, an array of Response::Artist objects will be returned.

=cut

sub artist_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $artist_list = $metadata->artist_list();

   return wantarray ? @{ $artist_list->artists() } : $artist_list;
}

=head2 release_list()

This method will return a reference to the Response::ReleaseList object in a scalar context.  If in a array context, an array of Response::Release objects will be returned.

=cut

sub release_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $release_list = $metadata->release_list();

   return wantarray ? @{ $release_list->releases() } : $release_list;
}

=head2 track_list()

This method will return a reference to the Response::TrackList object in a scalar context.  If in a array context, an array of Response::Track objects will be returned.

=cut

sub track_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $track_list = $metadata->track_list();

   return wantarray ? @{ $track_list->tracks() } : $track_list;
}

=head2 label_list()

This method will return a reference to the Response::LabelList object in a scalar context.  If in a array context, an array of Response::Label objects will be returned.

=cut

sub label_list {
   my $self = shift;

   my $metadata = $self->{_metadata_cache};

   my $label_list = $metadata->label_list();

   return wantarray ? @{ $label_list->labels() } : $label_list;
}

sub _create_artist {
   my $self = shift;
   my ($xArtist) = @_;

   my $xpc = $self->xpc();

   my ($xSortName) = $xpc->findnodes('mmd:sort-name[1]', $xArtist);
   my ($xName) = $xpc->findnodes('mmd:name[1]', $xArtist);
   my ($xDisambiguation) = $xpc->findnodes('mmd:disambiguation[1]', $xArtist);
   my ($xLifeSpan) = $xpc->findnodes('mmd:life-span[1]', $xArtist);
   my ($xAliasList) = $xpc->findnodes('mmd:alias-list[1]', $xArtist);
   my @xRelationList = $xpc->findnodes('mmd:relation-list', $xArtist);
   my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]', $xArtist);
   my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xArtist);
   my ($xReleaseGroupList) = $xpc->findnodes('mmd:release-group-list[1]', $xArtist);
   my ($xRating) = $xpc->findnodes('mmd:rating[1]', $xArtist);

   require WebService::MusicBrainz::Response::Artist;

   my $artist = WebService::MusicBrainz::Response::Artist->new();

   $artist->id( $xArtist->getAttribute('id') ) if $xArtist->getAttribute('id');
   $artist->type( $xArtist->getAttribute('type') ) if $xArtist->getAttribute('type');
   $artist->name( $xName->textContent() ) if $xName;
   $artist->sort_name( $xSortName->textContent() ) if $xSortName;
   $artist->disambiguation( $xDisambiguation->textContent() ) if $xDisambiguation;
   $artist->life_span_begin( $xLifeSpan->getAttribute('begin') ) if $xLifeSpan && $xLifeSpan->getAttribute('begin');
   $artist->life_span_end( $xLifeSpan->getAttribute('end') ) if $xLifeSpan && $xLifeSpan->getAttribute('end');
   $artist->score( $xArtist->getAttribute('ext:score') ) if $xArtist->getAttribute('ext:score');
   $artist->alias_list( $self->_create_alias_list( $xAliasList ) ) if $xAliasList;
   $artist->release_list( $self->_create_release_list( $xReleaseList ) ) if $xReleaseList;
   $artist->tag_list( $self->_create_tag_list( $xTagList ) ) if $xTagList;
   my $relationLists = $self->_create_relation_lists( \@xRelationList );
   $artist->relation_list( $relationLists->[0] ) if $relationLists;
   $artist->relation_lists( $relationLists ) if $relationLists;
   $artist->release_group_list( $self->_create_release_group_list( $xReleaseGroupList ) ) if $xReleaseGroupList;
   $artist->rating( $self->_create_rating( $xRating ) ) if $xRating;

   return $artist;
}

sub _create_artist_list {
   my $self = shift;
   my ($xArtistList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::ArtistList;

   my $artist_list = WebService::MusicBrainz::Response::ArtistList->new();

   $artist_list->count( $xArtistList->getAttribute('count') ) if $xArtistList->getAttribute('count');
   $artist_list->offset( $xArtistList->getAttribute('offset') ) if $xArtistList->getAttribute('offset');

   my @artists;

   foreach my $xArtist ($xpc->findnodes('mmd:artist', $xArtistList)) {
       my $artist = $self->_create_artist( $xArtist );

       push @artists, $artist;
   }

   $artist_list->artists( \@artists );

   return $artist_list;
}

sub _create_release {
   my $self = shift;
   my ($xRelease) = @_;

   my $xpc = $self->xpc();

   my ($xTitle) = $xpc->findnodes('mmd:title[1]', $xRelease);
   my ($xTextRep) = $xpc->findnodes('mmd:text-representation[1]', $xRelease);
   my ($xASIN) = $xpc->findnodes('mmd:asin[1]', $xRelease);
   my ($xArtist) = $xpc->findnodes('mmd:artist[1]', $xRelease);
   my ($xReleaseEventList) = $xpc->findnodes('mmd:release-event-list[1]', $xRelease);
   my ($xDiscList) = $xpc->findnodes('mmd:disc-list[1]', $xRelease);
   my ($xPuidList) = $xpc->findnodes('mmd:puid-list[1]', $xRelease);
   my ($xTrackList) = $xpc->findnodes('mmd:track-list[1]', $xRelease);
   my @xRelationList = $xpc->findnodes('mmd:relation-list', $xRelease);
   my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xRelease);

   require WebService::MusicBrainz::Response::Release;

   my $release = WebService::MusicBrainz::Response::Release->new();

   $release->id( $xRelease->getAttribute('id') ) if $xRelease->getAttribute('id');
   $release->type( $xRelease->getAttribute('type') ) if $xRelease->getAttribute('type');
   $release->title( $xTitle->textContent() ) if $xTitle;
   $release->text_rep_language( $xTextRep->getAttribute('language') ) if $xTextRep && $xTextRep->getAttribute('language');
   $release->text_rep_script( $xTextRep->getAttribute('script') ) if $xTextRep && $xTextRep->getAttribute('script');
   $release->asin( $xASIN->textContent() ) if $xASIN;
   $release->score( $xRelease->getAttribute('ext:score') ) if $xRelease->getAttribute('ext:score');
   $release->artist( $self->_create_artist( $xArtist ) ) if $xArtist;
   $release->release_event_list( $self->_create_release_event_list( $xReleaseEventList ) ) if $xReleaseEventList;
   $release->disc_list( $self->_create_disc_list( $xDiscList ) ) if $xDiscList;
   $release->puid_list( $self->_create_puid_list( $xPuidList ) ) if $xPuidList;
   $release->track_list( $self->_create_track_list( $xTrackList ) ) if $xTrackList;
   $release->tag_list( $self->_create_tag_list( $xTagList ) ) if $xTagList;

   my $relationLists = $self->_create_relation_lists( \@xRelationList );
   $release->relation_list( $relationLists->[0] ) if $relationLists;
   $release->relation_lists( $relationLists ) if $relationLists;

   return $release;
}

sub _create_track {
   my $self = shift;
   my ($xTrack) = @_;

   my $xpc = $self->xpc();

   my ($xTitle) = $xpc->findnodes('mmd:title[1]', $xTrack);
   my ($xDuration) = $xpc->findnodes('mmd:duration[1]', $xTrack);
   my ($xArtist) = $xpc->findnodes('mmd:artist[1]', $xTrack);
   my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]', $xTrack);
   my ($xPuidList) = $xpc->findnodes('mmd:puid-list[1]', $xTrack);
   my ($xISRCList) = $xpc->findnodes('mmd:isrc-list[1]', $xTrack);
   my @xRelationList = $xpc->findnodes('mmd:relation-list', $xTrack);
   my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xTrack);

   require WebService::MusicBrainz::Response::Track;

   my $track= WebService::MusicBrainz::Response::Track->new();

   $track->id( $xTrack->getAttribute('id') ) if $xTrack->getAttribute('id');
   $track->title( $xTitle->textContent() ) if $xTitle;
   $track->duration( $xDuration->textContent() ) if $xDuration;
   $track->score( $xTrack->getAttribute('ext:score') ) if $xTrack->getAttribute('ext:score');
   $track->artist( $self->_create_artist( $xArtist ) ) if $xArtist;
   $track->release_list( $self->_create_release_list( $xReleaseList ) ) if $xReleaseList;
   $track->puid_list( $self->_create_puid_list( $xPuidList ) ) if $xPuidList;
   $track->isrc_list( $self->_create_isrc_list( $xISRCList ) ) if $xISRCList;
   $track->tag_list( $self->_create_tag_list( $xTagList ) ) if $xTagList;

   my $relationLists = $self->_create_relation_lists( \@xRelationList );
   $track->relation_list( $relationLists->[0] ) if $relationLists;
   $track->relation_lists( $relationLists ) if $relationLists;

   return $track;
}

sub _create_label {
   my $self = shift;
   my ($xLabel) = @_;

   my $xpc = $self->xpc();

   my ($xName) = $xpc->findnodes('mmd:name[1]', $xLabel);
   my ($xSortName) = $xpc->findnodes('mmd:sort-name[1]', $xLabel);
   my ($xLabelCode) = $xpc->findnodes('mmd:label-code[1]', $xLabel);
   my ($xDisambiguation) = $xpc->findnodes('mmd:disambiguation[1]', $xLabel);
   my ($xCountry) = $xpc->findnodes('mmd:country[1]', $xLabel);
   my ($xLifeSpan) = $xpc->findnodes('mmd:life-span[1]', $xLabel);
   my ($xAliasList) = $xpc->findnodes('mmd:alias-list[1]', $xLabel);
   my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]', $xLabel);
   my @xRelationList = $xpc->findnodes('mmd:relation-list', $xLabel);
   my ($xTagList) = $xpc->findnodes('mmd:tag-list[1]', $xLabel);

   require WebService::MusicBrainz::Response::Label;

   my $label= WebService::MusicBrainz::Response::Label->new();

   $label->id( $xLabel->getAttribute('id') ) if $xLabel->getAttribute('id');
   $label->type( $xLabel->getAttribute('type') ) if $xLabel->getAttribute('type');
   $label->name( $xName->textContent() ) if $xName;
   $label->sort_name( $xSortName->textContent() ) if $xSortName;
   $label->label_code( $xLabelCode->textContent() ) if $xLabelCode;
   $label->disambiguation( $xDisambiguation->textContent() ) if $xDisambiguation;
   $label->country( $xCountry->textContent() ) if $xCountry;
   $label->life_span_begin( $xLifeSpan->getAttribute('begin') ) if $xLifeSpan;
   $label->life_span_end( $xLifeSpan->getAttribute('end') ) if $xLifeSpan;
   $label->score( $xLabel->getAttribute('ext:score') ) if $xLabel->getAttribute('ext:score');
   $label->alias_list( $self->_create_alias_list( $xAliasList ) ) if $xAliasList;
   $label->release_list( $self->_create_release_list( $xReleaseList ) ) if $xReleaseList;
   $label->tag_list( $self->_create_tag_list( $xTagList ) ) if $xTagList;

   my $relationLists = $self->_create_relation_lists( \@xRelationList );
   $label->relation_list( $relationLists->[0] ) if $relationLists;
   $label->relation_lists( $relationLists ) if $relationLists;
   
   return $label;
}

sub _create_label_list {
   my $self = shift;
   my ($xLabelList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::LabelList;

   my $label_list = WebService::MusicBrainz::Response::LabelList->new();

   $label_list->count( $xLabelList->getAttribute('count') ) if $xLabelList->getAttribute('count');
   $label_list->offset( $xLabelList->getAttribute('offset') ) if $xLabelList->getAttribute('offset');
   
   my @labels;

   foreach my $xLabel ($xpc->findnodes('mmd:label', $xLabelList)) {
       my $label = $self->_create_label( $xLabel );
       push @labels, $label;
   }

   $label_list->labels( \@labels );

   return $label_list;
}

sub _create_track_list {
   my $self = shift;
   my ($xTrackList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::TrackList;

   my $track_list = WebService::MusicBrainz::Response::TrackList->new();

   $track_list->count( $xTrackList->getAttribute('count') ) if $xTrackList->getAttribute('count');
   $track_list->offset( $xTrackList->getAttribute('offset') ) if $xTrackList->getAttribute('offset');

   my @tracks;

   foreach my $xTrack ($xpc->findnodes('mmd:track', $xTrackList)) {
       my $track = $self->_create_track( $xTrack );
       push @tracks, $track;
   }

   $track_list->tracks( \@tracks );

   return $track_list;
}

sub _create_alias {
   my $self = shift;
   my ($xAlias) = @_;

   require WebService::MusicBrainz::Response::Alias;

   my $alias = WebService::MusicBrainz::Response::Alias->new();

   $alias->type( $xAlias->getAttribute('type') ) if $xAlias->getAttribute('type');
   $alias->script( $xAlias->getAttribute('script') ) if $xAlias->getAttribute('script');
   $alias->text( $xAlias->textContent() ) if $xAlias->textContent();

   return $alias;
}

sub _create_alias_list {
   my $self = shift;
   my ($xAliasList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::AliasList;

   my $alias_list = WebService::MusicBrainz::Response::AliasList->new();

   $alias_list->count( $xAliasList->getAttribute('count') ) if $xAliasList->getAttribute('count');
   $alias_list->offset( $xAliasList->getAttribute('offset') ) if $xAliasList->getAttribute('offset');

   my @aliases;

   foreach my $xAlias ($xpc->findnodes('mmd:alias', $xAliasList)) {
       my $alias = $self->_create_alias($xAlias);

       push @aliases, $alias if defined($alias);
   }

   $alias_list->aliases( \@aliases );

   return $alias_list;
}

sub _create_relation {
   my $self = shift;
   my ($xRelation) = @_;

   my $xpc = $self->xpc();

   my ($xArtist) = $xpc->findnodes('mmd:artist[1]', $xRelation);
   my ($xRelease) = $xpc->findnodes('mmd:release[1]', $xRelation);
   my ($xTrack) = $xpc->findnodes('mmd:track[1]', $xRelation);
   my ($xLabel) = $xpc->findnodes('mmd:label[1]', $xRelation);

   require WebService::MusicBrainz::Response::Relation;

   my $relation = WebService::MusicBrainz::Response::Relation->new();

   $relation->type( $xRelation->getAttribute('type') ) if $xRelation->getAttribute('type');
   $relation->target( $xRelation->getAttribute('target') ) if $xRelation->getAttribute('target');
   $relation->direction( $xRelation->getAttribute('direction') ) if $xRelation->getAttribute('direction');
   $relation->attributes( $xRelation->getAttribute('attributes') ) if $xRelation->getAttribute('attributes');
   $relation->begin( $xRelation->getAttribute('begin') ) if $xRelation->getAttribute('begin');
   $relation->end( $xRelation->getAttribute('end') ) if $xRelation->getAttribute('end');
   $relation->score( $xRelation->getAttribute('ext:score') ) if $xRelation->getAttribute('ext:score');
   $relation->artist( $self->_create_artist( $xArtist ) ) if $xArtist;
   $relation->release( $self->_create_release( $xRelease ) ) if $xRelease;
   $relation->track( $self->_create_track( $xTrack ) ) if $xTrack;
   $relation->label( $self->_create_label( $xLabel ) ) if $xLabel;

   return $relation;
}

sub _create_relation_lists {
   my $self = shift;
   my ($xRelationLists) = @_;

   my @relation_lists;

   if($xRelationLists && scalar(@{ $xRelationLists }) > 0) {
       map { push @relation_lists, $self->_create_relation_list( $_ ) } @$xRelationLists;
   }

   return scalar(@relation_lists) > 0 ? \@relation_lists : undef;
}

sub _create_relation_list {
   my $self = shift;
   my ($xRelationList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::RelationList;

   my $relation_list = WebService::MusicBrainz::Response::RelationList->new();

   $relation_list->target_type( $xRelationList->getAttribute('target-type') ) if $xRelationList->getAttribute('target-type');
   $relation_list->count( $xRelationList->getAttribute('count') ) if $xRelationList->getAttribute('count');
   $relation_list->offset( $xRelationList->getAttribute('offset') ) if $xRelationList->getAttribute('offset');

   my @relations;

   foreach my $xRelation ($xpc->findnodes('mmd:relation', $xRelationList)) {
       my $relation = $self->_create_relation($xRelation);

       push @relations, $relation if defined($relation);
   }

   $relation_list->relations( \@relations );

   return $relation_list;
}

sub _create_event {
   my $self = shift;
   my ($xEvent) = @_;

   require WebService::MusicBrainz::Response::ReleaseEvent;

   my $event = WebService::MusicBrainz::Response::ReleaseEvent->new();

   $event->date( $xEvent->getAttribute('date') ) if $xEvent->getAttribute('date');
   $event->country( $xEvent->getAttribute('country') ) if $xEvent->getAttribute('country');
   $event->label( $xEvent->getAttribute('label') ) if $xEvent->getAttribute('label');
   $event->catalog_number( $xEvent->getAttribute('catalog-number') ) if $xEvent->getAttribute('catalog-number');
   $event->barcode( $xEvent->getAttribute('barcode') ) if $xEvent->getAttribute('barcode');
   $event->format( $xEvent->getAttribute('format') ) if $xEvent->getAttribute('format');

   return $event;
}

sub _create_release_event_list {
   my $self = shift;
   my ($xReleaseEventList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::ReleaseEventList;

   my $release_event_list = WebService::MusicBrainz::Response::ReleaseEventList->new();

   $release_event_list->count( $xReleaseEventList->getAttribute('count') ) if $xReleaseEventList->getAttribute('count');
   $release_event_list->offset( $xReleaseEventList->getAttribute('offset') ) if $xReleaseEventList->getAttribute('offset');

   my @events;

   foreach my $xEvent ($xpc->findnodes('mmd:event', $xReleaseEventList)) {
       my $event = $self->_create_event( $xEvent );
       push @events, $event;
   }

   $release_event_list->events( \@events );

   return $release_event_list;
}

sub _create_release_list {
   my $self = shift;
   my ($xReleaseList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::ReleaseList;

   my $release_list = WebService::MusicBrainz::Response::ReleaseList->new();

   $release_list->count( $xReleaseList->getAttribute('count') ) if $xReleaseList->getAttribute('count');
   $release_list->offset( $xReleaseList->getAttribute('offset') ) if $xReleaseList->getAttribute('offset');

   my @releases;

   foreach my $xRelease ($xpc->findnodes('mmd:release', $xReleaseList)) {
       my $release = $self->_create_release($xRelease);

       push @releases, $release if defined($release);
   }

   $release_list->releases( \@releases );

   return $release_list;
}

sub _create_disc {
   my $self = shift;
   my ($xDisc) = @_;

   require WebService::MusicBrainz::Response::Disc;

   my $disc = WebService::MusicBrainz::Response::Disc->new();

   $disc->id( $xDisc->getAttribute('id') ) if $xDisc->getAttribute('id');
   $disc->sectors( $xDisc->getAttribute('sectors') ) if $xDisc->getAttribute('sectors');

   return $disc;
}

sub _create_disc_list {
   my $self = shift;
   my ($xDiscList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::DiscList;

   my $disc_list = WebService::MusicBrainz::Response::DiscList->new();

   my @discs;

   $disc_list->count( $xDiscList->getAttribute('count') ) if $xDiscList->getAttribute('count');
   $disc_list->offset( $xDiscList->getAttribute('offset') ) if $xDiscList->getAttribute('offset');

   foreach my $xDisc ($xpc->findnodes('mmd:disc', $xDiscList)) {
      my $disc = $self->_create_disc( $xDisc );
      push @discs, $disc;
   }

   $disc_list->discs( \@discs );

   return $disc_list;
}

sub _create_puid {
   my $self = shift;
   my ($xPuid) = @_;

   require WebService::MusicBrainz::Response::Puid;

   my $puid = WebService::MusicBrainz::Response::Puid->new();

   $puid->id( $xPuid->getAttribute('id') ) if $xPuid->getAttribute('id');

   return $puid;
}

sub _create_puid_list {
   my $self = shift;
   my ($xPuidList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::PuidList;

   my $puid_list = WebService::MusicBrainz::Response::PuidList->new();

   $puid_list->count( $xPuidList->getAttribute('count') ) if $xPuidList->getAttribute('count');
   $puid_list->offset( $xPuidList->getAttribute('offset') ) if $xPuidList->getAttribute('offset');

   my @puids;

   foreach my $xPuid ($xpc->findnodes('mmd:puid', $xPuidList)) {
       my $puid = $self->_create_puid( $xPuid );
       push @puids, $puid;
   }

   $puid_list->puids( \@puids );

   return $puid_list;
}

sub _create_tag {
   my $self = shift;
   my ($xTag) = @_;

   require WebService::MusicBrainz::Response::Tag;

   my $tag = WebService::MusicBrainz::Response::Tag->new();

   $tag->id( $xTag->getAttribute('id') ) if $xTag->getAttribute('id');
   $tag->count( $xTag->getAttribute('count') ) if $xTag->getAttribute('count');
   $tag->text( $xTag->textContent() ) if $xTag->textContent();

   return $tag;
}

sub _create_tag_list {
   my $self = shift;
   my ($xTagList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::TagList;

   my $tag_list = WebService::MusicBrainz::Response::TagList->new();

   $tag_list->count( $xTagList->getAttribute('count') ) if $xTagList->getAttribute('count');
   $tag_list->offset( $xTagList->getAttribute('offset') ) if $xTagList->getAttribute('offset');

   my @tags;

   foreach my $xTag ($xpc->findnodes('mmd:tag', $xTagList)) {
       my $tag = $self->_create_tag( $xTag );
       push @tags, $tag;
   }

   $tag_list->tags( \@tags );

   return $tag_list;
}

sub _create_isrc {
   my $self = shift;
   my ($xIsrc) = @_;

   require WebService::MusicBrainz::Response::ISRC;

   my $isrc = WebService::MusicBrainz::Response::ISRC->new();

   $isrc->id( $xIsrc->getAttribute('id') ) if $xIsrc->getAttribute('id');

   return $isrc;
}

sub _create_isrc_list {
   my $self = shift;
   my ($xIsrcList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::ISRCList;

   my $isrc_list = WebService::MusicBrainz::Response::ISRCList->new();

   $isrc_list->count( $xIsrcList->getAttribute('count') ) if $xIsrcList->getAttribute('count');
   $isrc_list->offset( $xIsrcList->getAttribute('offset') ) if $xIsrcList->getAttribute('offset');

   my @isrcs;

   foreach my $xIsrc ($xpc->findnodes('mmd:isrc', $xIsrcList)) {
       my $isrc = $self->_create_isrc( $xIsrc );
       push @isrcs, $isrc;
   }

   $isrc_list->isrcs( \@isrcs );

   return $isrc_list;
}

sub _create_release_group {
   my $self = shift;
   my ($xReleaseGroup) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::ReleaseGroup;

   my $rel_group = WebService::MusicBrainz::Response::ReleaseGroup->new();

   $rel_group->id( $xReleaseGroup->getAttribute('id') ) if $xReleaseGroup->getAttribute('id');
   $rel_group->type( $xReleaseGroup->getAttribute('type') ) if $xReleaseGroup->getAttribute('type');

   my ($xTitle) = $xpc->findnodes('mmd:title[1]', $xReleaseGroup);

   $rel_group->title( $xTitle->textContent() ) if $xTitle;

   my ($xArtist) = $xpc->findnodes('mmd:artist[1]', $xReleaseGroup);
   my ($xReleaseList) = $xpc->findnodes('mmd:release-list[1]', $xReleaseGroup);

   $rel_group->artist( $self->_create_artist( $xArtist ) ) if $xArtist;
   $rel_group->release_list( $self->_create_release_list( $xReleaseList ) ) if $xReleaseList;

   return $rel_group;
}

sub _create_release_group_list {
   my $self = shift;
   my ($xReleaseGroupList) = @_;

   my $xpc = $self->xpc();

   require WebService::MusicBrainz::Response::ReleaseGroupList;

   my $rel_group_list = WebService::MusicBrainz::Response::ReleaseGroupList->new();

   $rel_group_list->count( $xReleaseGroupList->getAttribute('count') ) if $xReleaseGroupList->getAttribute('count');
   $rel_group_list->offset( $xReleaseGroupList->getAttribute('offset') ) if $xReleaseGroupList->getAttribute('offset');
   $rel_group_list->score( $xReleaseGroupList->getAttribute('ext:score') ) if $xReleaseGroupList->getAttribute('ext:score');

   my @rel_groups;

   foreach my $xReleaseGroup ($xpc->findnodes('mmd:release-group', $xReleaseGroupList)) {
       my $rel_group = $self->_create_release_group( $xReleaseGroup );
       push @rel_groups, $rel_group;
   }

   $rel_group_list->release_groups( \@rel_groups );

   return $rel_group_list;
}

sub _create_rating {
   my $self = shift;
   my ($xRating) = @_;

   require WebService::MusicBrainz::Response::Rating;

   my $rating = WebService::MusicBrainz::Response::Rating->new();

   $rating->votes_count( $xRating->getAttribute('votes-count') ) if $xRating->getAttribute('votes-count');
   $rating->value( $xRating->textContent() ) if $xRating->textContent();

   return $rating;
}

=head1 AUTHOR

=over 4

=item Bob Faist <bob.faist@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2007 by Bob Faist

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

http://wiki.musicbrainz.org/XMLWebService

=cut

1;
