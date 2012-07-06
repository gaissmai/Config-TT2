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

done_testing();
