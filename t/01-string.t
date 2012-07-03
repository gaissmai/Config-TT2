#!perl -T

use Test::More;

BEGIN {
    use_ok('Config::TT') || print "Bail out!\n";
}

my $template;
my $cfg;
my $stash;

$template = Config::TT->new;
isa_ok( $template, 'Config::TT' );

$cfg   = '[% foo = 1 %]';
$stash = $template->process( \$cfg );
isa_ok( $stash, 'Template::Stash' );
diag explain $stash;
is_deeply( $stash, { foo => 1 }, 'SCALAR' );

$cfg   = "[% foo = [1 2 3 4] %]";
$stash = $template->process( \$cfg );
is_deeply( $stash, { foo => [ 1, 2, 3, 4 ] }, 'ARRAY' );

$cfg = '[% foo = bar %]';
eval '$stash = $template->process(\$cfg)';
like( $@, qr/\Qvar.undef\E/, 'STRICT croaks on var.undef error' );

$cfg = '[% foo = bar %]';
$stash = $template->process( \$cfg, { bar => 'baz' } );
is_deeply( $stash, { bar => 'baz', foo => 'baz' }, 'prefilled stash' );

$cfg = '[% foo = bar %]';
$stash = $template->process( \$cfg, { bar => [ 1, 2, 3, 4 ] } );
is_deeply( $stash->get('foo'), [ 1, 2, 3, 4 ], 'compound prefilled stash' );

$cfg = '[% foo = bar.3 %]';
$stash = $template->process( \$cfg, { bar => [ 1, 2, 3, 4 ] } );
is_deeply( $stash->get('foo'), 4, 'compound prefilled stash 2 ' );

done_testing();
