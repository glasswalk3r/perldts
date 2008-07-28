use warnings;
use strict;

use Test::More;
use XML::Simple;
use DTS::Application;
use DTS::Assignment::Destination::Connection;

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

  TODO: {

        local $TODO =
          'Tests for DTS::Assignment::Destination classes are not finished';

        isa_ok(
            $assignment->get_destination(),
            'DTS::Assignment::Destination',
            'get_destination returns a DTS::Assignment::Destination object'
        );

        like( $assignment->get_destination,
            qr/[\w\;\(\)\s]+$/,
            'get_destination returns a string with semicolons characters' );

        #and test other methods

    }

}

