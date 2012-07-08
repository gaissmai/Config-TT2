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
        name   => 'META',
        vars   => undef,
        cfg    => '[% META title = "bar" %]',
        expect => { global => {} },
    };

$tcfg = Config::TT->new();
$stash = $tcfg->process( \$test->{cfg}, $test->{vars} );
is_deeply( $stash, $test->{expect}, $test->{name} );
diag explain $stash;

done_testing();

