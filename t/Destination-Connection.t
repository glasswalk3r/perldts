use Test::More tests => 7;
use Test::Exception;

BEGIN { use_ok('DTS::Assignment::Destination::Connection') }

can_ok(
    'DTS::Assignment::Destination::Connection',
    qw(new
      initialize
      get_destination
      get_string
      get_raw_string
      set_string
      changes)
);

require DTS::Assignment::Destination::Connection;

my $dest_conn = DTS::Assignment::Destination::Connection->new(
    "'Connections';'Database connection';'Properties';'Datasource'");

is( $dest_conn->get_destination(),
    'Datasource', 'get_destination returns "Datasource"' );

is(
    $dest_conn->get_string(),
    'Connections;Database connection;Properties;Datasource',
    'get_string returns the expected string'
);

ok( $dest_conn->changes('Connection'), 'object changes a connection' );

ok(
    $dest_conn->set_string(
        "'Connections';'New connection';'Properties';'Datasource'"),
    'set_string accepts a valid destination string'
);

dies_ok(
    sub { $dest_conn->set_string('#&¨%!|##$#') },
    'set_string aborts with an invalid string'
);

