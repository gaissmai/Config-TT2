#!perl -T

use Test::More;

BEGIN {
    use_ok( 'Config::TT' ) || print "Bail out!\n";
}

my $t = Config::TT->new;
isa_ok($t, 'Config::TT');

my $cfg = <<EOC;
[% foo = 1 %]
EOC

my $s = $t->process(\$cfg);

done_testing();
