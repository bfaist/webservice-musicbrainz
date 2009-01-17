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
                  'URI' => '1.35',
                 },
     create_makefile_pl => 'traditional',
     dist_author => 'Bob Faist <bob.faist@gmail.com>',
);
$build->create_build_script;
