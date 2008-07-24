use warnings;
use strict;
use XML::Simple;
use DTS::Application;

my $xml_file = 'modify.xml';
my $xml      = XML::Simple->new();
my $config   = $xml->XMLin($xml_file);

my $app = DTS::Application->new( $config->{credential} );
my $package = $app->get_db_package( { name => $config->{package} } );

foreach my $dyn_prop ( @{ $package->get_dynamic_props() } ) {

    my $iterator = $dyn_prop->get_assignments();

    while ( my $assignment = $iterator->() ) {

        print 'old: ', $assignment->get_sibling()->{DestinationPropertyID},
          "\n";

        my $dest = $assignment->get_destination();

        if ( $dest->changes('GlobalVar') ) {

            if ( $dest->get_destination() eq 'computer_name' ) {

                $dest->set_string(
'\'Global Variables\';\'v_computer_name\';\'Properties\';\'Value\''
                );

            }

        }

        print 'new: ', $assignment->get_sibling()->{DestinationPropertyID},
          "\n";

    }

}

$package->save_to_server( $app->get_credential()->to_list() );
