use XML::Simple;
use Test::More;
use Test::Exception;
use DTS::Application;
use DTS::Assignment;
use Win32::OLE qw(in);

my $xml_file = 'test-config.xml';
my $xml      = XML::Simple->new();
my $config   = $xml->XMLin($xml_file);

my $app = DTS::Application->new( $config->{credential} );
my $package = $app->get_db_package( { name => $config->{package} } );

# test-all DTS package has only only Dynamic Properties Task
my $dyn_props = @{ $package->get_dynamic_props }[0];

plan tests => 6 * $dyn_props->count_assignments;

my $assignments = $dyn_props->get_sibling->Assignments;

foreach my $assignment ( in($assignments) ) {

    my $dts_assignment = DTS::Assignment->new($assignment);

    # test the new method new
    isa_ok( $dts_assignment, 'DTS::Assignment' );
    like( $dts_assignment->get_type, qr/^\d$/, 'get_type returns an integer' );

    dies_ok( sub { $dts_assignment->get_source }, 'get_source should die' );
    dies_ok( sub { $dts_assignment->get_properties },
        'get_properties should die due get_source method not be overrided' );
    dies_ok( sub { $dts_assignment->to_string },
        'to_string should die due get_source method not be overrided' );

    like( $dts_assignment->get_destination,
        qr/[\w\;\(\)\s]+$/,
        'get_destination returns a string with semicolons characters' );
}

