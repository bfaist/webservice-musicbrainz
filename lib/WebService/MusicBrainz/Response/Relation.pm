package WebService::MusicBrainz::Response::Relation;

use strict;
use base 'Class::Accessor';

our $VERSION = '0.91';

=head1 NAME

WebService::MusicBrainz::Response::Relation

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

All the methods listed below are accessor methods.  They can take a scalar argument to set the state of the object or without and argument, they will return that state if it is available.

=head2 type()

=head2 target()

=head2 direction()

=head2 attributes()

=head2 begin()

=head2 end()

=head2 artist()

=head2 release()

=head2 track()

=head2 score()

=cut

__PACKAGE__->mk_accessors(qw/type target direction attributes begin end artist release track label score/);

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
