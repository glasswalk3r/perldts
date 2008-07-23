use XML::Simple;
use Test::More;
use Test::Exception;
use DTS::Application;
use DTS::Assignment;

my $xml_file = 'test-config.xml';
my $xml      = XML::Simple->new();
my $config   = $xml->XMLin($xml_file);

my $app = DTS::Application->new( $config->{credential} );
my $package = $app->get_db_package( { name => $config->{package} } );

# test-all DTS package has only only Dynamic Properties Task
my $dyn_props = @{ $package->get_dynamic_props }[0];

plan tests => 6 * $dyn_props->count_assignments;

my $assign_iterator = $dyn_props->get_assignments();

while ( my $assignment = $assign_iterator->() ) {

    # test the new method new
    isa_ok( $assignment, 'DTS::Assignment' );
    like( $assignment->get_type, qr/^\d$/, 'get_type returns an integer' );

    dies_ok( sub { $assignment->get_source() }, 'get_source should die' );
    dies_ok( sub { $assignment->get_properties() },
        'get_properties should die due get_source method not be overrided' );
    dies_ok( sub { $assignment->to_string() },
        'to_string should die due get_source method not be overrided' );

    isa_ok( $assignment->get_destination(), 'DTS::Assignment::Destination' );
}

