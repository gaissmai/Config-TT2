#!perl -T

use Test::More;

use_ok('Config::TT');
my $t = Config::TT->new();
isa_ok( $t, 'Config::TT' );

{
    foreach my $opt (
        qw/
        NAMESPACE
        CONSTANTS
        CONSTANTS_NAMESPACE
        PRE_PROCESS
        PROCESS
        POST_PROCESS
        AUTO_RESET ERROR
        SERVICE
        OUTPUT
        OUTPUT_PATH
        /
      )
    {
        my $warning;
        local $SIG{__WARN__} = sub { $warning = shift };

        Config::TT->new( $opt => 0 );
        like( $warning, qr/$opt/i, "unsupported option $opt" );
    }
}

done_testing();

