#!perl -T

use Test::More;
use Try::Tiny;

BEGIN {
    use_ok('Config::TT') || print "Bail out!\n";
}

my $tcfg;
my $stash;
my $test;

$test = 
    {
        name   => 'default namespace',
        vars   => undef,
        cfg    => '[% user = constants.user %]',
        expect => { user => 'homer' },
    };

$tcfg = Config::TT->new(CONSTANTS => { user => 'homer' });
$stash = $tcfg->process( \$test->{cfg}, $test->{vars} );
delete $stash->{global};
is_deeply( $stash, $test->{expect}, $test->{name} );

$test = 
    {
        name   => 'custom namespace',
        vars   => undef,
        cfg    => '[% user = my.user %]',
        expect => { user => 'homer' },
    };

$tcfg = Config::TT->new(
    CONSTANTS           => { user => 'homer' },
    CONSTANTS_NAMESPACE => 'my'
);
$stash = $tcfg->process( \$test->{cfg}, $test->{vars} );
delete $stash->{global};
is_deeply( $stash, $test->{expect}, $test->{name} );


done_testing();

