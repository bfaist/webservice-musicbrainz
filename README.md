# WebService-MusicBrainz

This module will search the MusicBrainz database through their web service and return objects with the found data.

## INSTALLATION

To install this module, using the ExtUtils::MakeMaker method:

     perl Makefile.PL
     make
     make test
     make install

To install this module using the Module::Build method:

     perl Build.PL
     ./Build
     ./Build test
     ./Build install

## DEPENDENCIES

This module requires these other modules and libraries:

* XML::LibXML
* LWP::UserAgent
* Class::Accessor
* URI
* Test::More

## NOTE

I have seen the tests fail if the musicbrainz database server is overloaded.
If this is happening, I would suggest installing during a non-peak time of the day.

COPYRIGHT AND LICENCE

Copyright (C) 2007-2016 by Bob Faist ( bob.faist at gmail.com )

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


