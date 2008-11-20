use Test::More tests => 2;
use Win32::OLE::Variant;

BEGIN { use_ok('Win32::SqlServer::DTS::DateTime') }

my $date_variant = Variant( VT_DATE, "April 1 99" );
my $date = Win32::SqlServer::DTS::DateTime->new($date_variant);

isa_ok( $date, 'DateTime' );
