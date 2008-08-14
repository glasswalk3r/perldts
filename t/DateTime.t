use Test::More tests => 2;
use Win32::OLE::Variant;

BEGIN { use_ok('DTS::DateTime') }

my $date_variant = Variant( VT_DATE, "April 1 99" );
my $date = DTS::DateTime->new($date_variant);

isa_ok( $date, 'DateTime' );
