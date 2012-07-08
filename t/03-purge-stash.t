#!perl -T

use Test::More;
use Try::Tiny;

BEGIN {
    use_ok('Config::TT') || print "Bail out!\n";
}

my $tcfg;
my $stash;

$tcfg = Config::TT->new;
isa_ok( $tcfg, 'Config::TT' );

my $tests = [
    {
        name   => 'used global as scalar',
        vars   => undef,
        cfg    => '[% global = 1 %]',
        expect => { global => 1 },
    },

    {
        name   => 'used global as struct',
        vars   => undef,
        cfg    => '[% global.foo = 1 %]',
        expect => { global => {foo => 1} },
    },

    {
        name   => 'used predefined global as struct',
        vars   => { global => [ 1, 2, 3, 4 ] },
        cfg    => '',
        expect => { global => [ 1, 2, 3, 4 ] },
    },

    {
        name   => 'change predefined global',
        vars   => { global => [ 1, 2, 3, 4 ] },
        cfg    => '[% global.0 = 0 %]',
        expect => { global => [ 0, 2, 3, 4 ] },
    },

    {
        name   => 'component not possible as toplevel var',
        vars   => undef,
        cfg    => '[% component = 1 %]',
        expect => { },
    },

    {
        name   => 'component possible as sublevel var',
        vars   => undef,
        cfg    => '[% foo.component = 1 %]',
        expect => { foo => { component => 1 } },
    },

    {
        name   => 'component predefined as sublevel var',
        vars   => { foo => { component => 1 } },
        cfg    => '',
        expect => { foo => { component => 1 } },
    },

];

foreach my $test (@$tests) {
    my $stash = $tcfg->process( \$test->{cfg}, $test->{vars} );
    is_deeply( $stash, $test->{expect}, $test->{name} );
} 


done_testing();

