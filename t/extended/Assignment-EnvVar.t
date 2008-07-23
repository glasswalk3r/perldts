use XML::Simple;
use Test::More tests => 6;
use DTS::Application;
use DTS::Assignment::EnvVar;
use Win32::OLE qw(in);

my $xml_file = 'test-config.xml';
my $xml      = XML::Simple->new();
my $config   = $xml->XMLin($xml_file);

my $app = DTS::Application->new( $config->{credential} );
my $package = $app->get_db_package( { name => $config->{package} } );

# test-all DTS package has only only Dynamic Properties Task
my $dyn_props = @{ $package->get_dynamic_props }[0];

# these are the values available in the DTS package
# (hey, I looked thru DTS Designer to get them!)
my $type_code   = 3;
my $source      = 'COMPUTERNAME';
my $destination = 'Global Variables;computer_name;Properties;Value';

my $assignments = $dyn_props->get_sibling->Assignments;

foreach my $assignment ( in($assignments) ) {

    next unless ( $assignment->SourceType == $type_code );

    my $dts_assignment = DTS::Assignment::EnvVar->new($assignment);

    $dts_assignment->debug;

    # test the new method new
    isa_ok( $dts_assignment, 'DTS::Assignment::EnvVar' );
    is( $dts_assignment->get_type, $type_code, "get_type returns $type_code" );

    is( $dts_assignment->get_source, $source, "get_source returns $source" );
    is_deeply(
        $dts_assignment->get_properties,
        {
            type        => $type_code,
            source      => $source,
            destination => $destination
        },
        'get_properties returns a hash reference'
    );
    like( $dts_assignment->to_string, qr/[\w\n]+/,
        'to_string returns a string with new line characters' );

    like( $dts_assignment->get_destination,
        qr/[\w\;\(\)\s]+$/,
        'get_destination returns a string with semicolons characters' );

}

