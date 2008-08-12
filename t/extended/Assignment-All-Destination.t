use warnings;
use strict;

use Test::More;
use XML::Simple;
use DTS::Application;

#use DTS::Assignment::Destination::Connection;

my $xml_file = 'test-config.xml';
my $xml      = XML::Simple->new();
my $config   = $xml->XMLin($xml_file);

my $app = DTS::Application->new( $config->{credential} );
my $package = $app->get_db_package( { name => $config->{package} } );

# test-all DTS package has only one Dynamic Properties Task
my $dyn_props = @{ $package->get_dynamic_props }[0];

plan tests => $dyn_props->count_assignments() * 2;

my $assign_iterator = $dyn_props->get_assignments();

while ( my $assignment = $assign_iterator->() ) {

    my $destination = $assignment->get_destination();

    isa_ok( $destination, 'DTS::Assignment::Destination',
        'destination is a subclass from DTS::Assignment::Destination superclass'
    );

    like(
        $destination->get_raw_string(),
        qr/^(\'[\w\s\(\)]+\'\;\'[\w\s\(\)]+\')(\'[\w\s\(\)]+\')*/,
        'get_raw_string returns a valid string'
    );

    #and test other methods

}

