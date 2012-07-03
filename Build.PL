use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Config::TT',
    license             => 'perl',
    dist_author         => q{Karl Gaissmaier <gaissmai@cpan.org>},
    dist_version_from   => 'lib/Config/TT.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Template' => '2.24',
    },
    add_to_cleanup      => [ 'Config-TT-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
