#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Config::TT' ) || print "Bail out!\n";
}

diag( "Testing Config::TT $Config::TT::VERSION, Perl $], $^X" );
