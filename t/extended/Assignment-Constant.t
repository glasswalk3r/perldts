use XML::Simple;
use Test::More tests => 6;
use DTS::Application;
use DTS::Assignment::Constant;
use Win32::OLE qw(in);

my $xml_file = 'test-config.xml';
my $xml      = XML::Simple->new();
my $config   = $xml->XMLin($xml_file);

my $app = DTS::Application->new( $config->{credential} );
my $package = $app->get_db_package( { name => $config->{package} } );

# test-all DTS package has only only Dynamic Properties Task
my $dyn_props = @{ $package->get_dynamic_props }[0];

my $assignments = $dyn_props->get_sibling->Assignments;

foreach my $assignment ( in($assignments) ) {

    next unless ( $assignment->SourceType == 4 );

    my $dts_assignment = DTS::Assignment::Constant->new($assignment);

    # test the new method new
    isa_ok( $dts_assignment, 'DTS::Assignment::Constant' );
    is( $dts_assignment->get_type, 4, 'get_type returns 4' );

    is( $dts_assignment->get_source, 'dts-testing',
        'get_source returns "dts-testing"' );
    is_deeply(
        $dts_assignment->get_properties,
        {
            type        => 4,
            source      => 'dts-testing',
            destination => 'Tasks;DTSTask_DTSSendMailTask_1;Properties;Profile'
        },
        'get_properties returns a hash reference'
    );
    like( $dts_assignment->to_string, qr/[\w\n]+/,
        'to_string returns a string with new line characters' );

    like( $dts_assignment->get_destination,
        qr/[\w\;\(\)\s]+$/,
        'get_destination returns a string with semicolons characters' );

}

