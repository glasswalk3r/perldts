use XML::Simple;
use Test::More tests => 6;
use DTS::Application;
use DTS::Assignment::DataFile;
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

    next unless ( $assignment->SourceType == 5 );

    my $dts_assignment = DTS::Assignment::DataFile->new($assignment);

    # test the new method new
    isa_ok( $dts_assignment, 'DTS::Assignment::DataFile' );
    is( $dts_assignment->get_type, 5, 'get_type returns 5' );

    is(
        $dts_assignment->get_source,
        'E:\dts\perl_dts\DTS\test-all.txt',
        'get_source returns E:\dts\perl_dts\DTS\test-all.txt'
    );
    is_deeply(
        $dts_assignment->get_properties,
        {
            type   => 5,
            source => 'E:\dts\perl_dts\DTS\test-all.txt',
            destination =>
              'Connections;Text File (Source);Properties;DataSource'
        },
        'get_properties returns a hash reference'
    );
    like( $dts_assignment->to_string, qr/[\w\n]+/,
        'to_string returns a string with new line characters' );

    like( $dts_assignment->get_destination,
        qr/[\w\;\(\)\s]+$/,
        'get_destination returns a string with semicolons characters' );

}

