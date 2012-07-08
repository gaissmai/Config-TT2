#!perl -T

use Test::More;
use Try::Tiny;

use_ok('Config::TT');
my $t = Config::TT->new();
isa_ok( $t, 'Config::TT' );

foreach my $opt (
    qw/
    PRE_PROCESS
    PROCESS
    POST_PROCESS
    WRAPPER
    AUTO_RESET
    OUTPUT
    OUTPUT_PATH
    ERROR
    ERRORS
    /
  )
{
    my $error;
    try {
        Config::TT->new( $opt => 0 );
    }
    catch { $error = $_ };

    like( $error, qr/$opt/i, "unsupported option $opt" );
}

{
    my $error;
    try {
        Config::TT->new( PRE_DEFINE => {'component' => 0} );
    }
    catch { $error = $_ };

    like( $error, qr/not supported/i, "check limit croaks" );
}

{
    my $error;
    try {
        Config::TT->new( VARIABLES => {'component' => 0} );
    }
    catch { $error = $_ };

    like( $error, qr/not supported/i, "check limit croaks" );
}

done_testing();

