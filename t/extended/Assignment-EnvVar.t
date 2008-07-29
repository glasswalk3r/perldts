use strict;
use warnings;

use XML::Simple;
use Test::More tests => 5;
use DTS::Application;

my $xml_file = 'test-config.xml';
my $xml      = XML::Simple->new();
my $config   = $xml->XMLin($xml_file);

my $app = DTS::Application->new( $config->{credential} );
my $package = $app->get_db_package( { name => $config->{package} } );

# test-all DTS package has only one Dynamic Properties Task
my $dyn_props = @{ $package->get_dynamic_props }[0];

# these are the values available in the DTS package
# (hey, I looked thru DTS Designer to get them!)
my $source    = 'COMPUTERNAME';
my $type_code = 3;

my $assign_iterator = $dyn_props->get_assignments();

while ( my $assignment = $assign_iterator->() ) {

    next unless ( $assignment->get_type_name() eq 'EnvVar' );

    # test the new method new
    isa_ok( $assignment, 'DTS::Assignment::EnvVar' );

    is( $assignment->get_type, $type_code, "get_type returns $type_code" );

    is( $assignment->get_source, $source, "get_source returns $source" );

    is_deeply(
        $assignment->get_properties(),
        {
            type        => $type_code,
            source      => $source,
            destination => DTS::Assignment::Destination::GlobalVar->new(
                q{'Global Variables';'computer_name';'Properties';'Value'}
            )
        },
        'get_properties returns a well defined hash reference'
    );

    like( $assignment->to_string(),
        qr/[\w\n]+/, 'to_string returns a string with new line characters' );

}

