use XML::Simple;
use Test::More tests => 2;
use DTS::Application;
use Win32::OLE qw(in);

my $xml_file = 'test-config.xml';
my $xml      = XML::Simple->new();
my $config   = $xml->XMLin($xml_file);

my $app = DTS::Application->new( $config->{credential} );
my $package = $app->get_db_package( { name => $config->{package} } );

is( ref( $package->get_steps() ),
    'CODE', 'get_steps method returns a code reference' );

my $steps = $package->get_sibling()->Steps;
my $collection;

foreach my $step ( in($steps) ) {

    my $new_step = DTS::Package::Step->new($step);

    push( @{$collection}, $new_step );

}

is_deeply( $package->execute(), $collection,
    'execute method returns an array reference with DTS::Package::Step objects'
);
