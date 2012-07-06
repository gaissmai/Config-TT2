#!perl -T

use Test::More;

BEGIN {
    use_ok('Config::TT') || print "Bail out!\n";
}

my $tcfg;
my $cfg;
my $stash;

$tcfg = Config::TT->new;
isa_ok( $tcfg, 'Config::TT' );

my $tests = [
    {
        name   => 'simple scalar',
        vars   => undef,
        cfg    => '[% foo = 1 %]',
        expect => { foo => 1 }
    },

    {
        name   => 'simple scalar, predefined var',
        vars   => { bar => 'baz' },
        cfg    => '[% foo = bar %]',
        expect => { foo => 'baz', bar => 'baz' }
    },

    {
        name   => 'list and join',
        vars   => undef,
        cfg    => '[% foo = [1 2 3 4]; bar = foo.join(":") %]',
        expect => { foo => [ 1, 2, 3, 4 ], bar => '1:2:3:4' }
    },

    {
        name => 'hash and import',
        vars => { hash2 => { one => 1, two => 2 } },
        cfg  => '[% foo = {}; foo.import(hash2) %]',
        expect =>
          { foo => { one => 1, two => 2 }, hash2 => { one => 1, two => 2 } }
    },

];

foreach my $test (@$tests) {
    my $stash = $tcfg->process( \$test->{cfg}, $test->{vars} );
    is_deeply( $stash, $test->{expect}, $test->{name} );
} 


done_testing();

=pod

$cfg   = '[% foo = 1 %]';
$stash = $tcfg->process( \$cfg );
isa_ok( $stash, 'Template::Stash' );
is_deeply( $stash, { foo => 1 }, 'SCALAR' );

$cfg   = "[% foo = [1 2 3 4] %]";
$stash = $tcfg->process( \$cfg );
is_deeply( $stash, { foo => [ 1, 2, 3, 4 ] }, 'ARRAY' );

$cfg = '[% foo = bar %]';
eval '$stash = $tcfg->process(\$cfg)';
like( $@, qr/\Qvar.undef\E/, 'STRICT croaks on var.undef error' );

$cfg = '[% foo = bar %]';
$stash = $tcfg->process( \$cfg, { bar => 'baz' } );
is_deeply( $stash, { bar => 'baz', foo => 'baz' }, 'prefilled stash' );

$cfg = '[% foo = bar %]';
$stash = $tcfg->process( \$cfg, { bar => [ 1, 2, 3, 4 ] } );
is_deeply(
    $stash,
    { bar => [ 1, 2, 3, 4 ], foo => [ 1, 2, 3, 4 ] },
    'compound prefilled stash'
);

$cfg = '[% foo = bar.3 %]';
$stash = $tcfg->process( \$cfg, { bar => [ 1, 2, 3, 4 ] } );
is_deeply(
    $stash,
    { bar => [ 1, 2, 3, 4 ], foo => 4 },
    'compound prefilled stash 2 '
);

$cfg = '[% global = [1 2 3 4] %]';
$stash = $tcfg->process( \$cfg );
is_deeply( $stash, { global => [ 1, 2, 3, 4 ] }, 'global' );

$cfg = '';
$stash = $tcfg->process( \$cfg, { global => [ 1, 2, 3, 4 ] } );
is_deeply( $stash, { global => [ 1, 2, 3, 4 ] }, 'global 2' );

$cfg = '';
$stash = $tcfg->process( \$cfg, { component => [ 1, 2, 3, 4 ] } );
is_deeply( $stash, { component => [ 1, 2, 3, 4 ] }, 'component' );

