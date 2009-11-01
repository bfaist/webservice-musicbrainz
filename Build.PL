use Module::Build;
my $build = Module::Build->new
(
     module_name => 'WebService::MusicBrainz',
     dist_abstract => 'Web service API to MusicBrainz database',
     license  => 'perl',
     requires => {
                  'perl'          => '5.7.0',
                  'XML::LibXML'   => '1.63',
                  'LWP::UserAgent' => '2.0',
                  'Class::Accessor' => '0.30',
                  'Test::More' => '0.88',
                  'URI' => '1.35',
                 },
     create_makefile_pl => 'traditional',
     dist_author => 'Bob Faist <bob.faist@gmail.com>',
     dist_version => '0.92',
     meta_merge => {
        resources => {
           repository => 'git://github.com/bfaist/webservice-musicbrainz.git'
        },
        keywords => [ qw/musicbrainz webservice/ ]
     },
);
$build->create_build_script;
