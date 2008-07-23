use Test::More tests => 2;
BEGIN { use_ok('DTS::Assignment::DataFile') }

can_ok( 'DTS::Assignment::DataFile',
    qw(new get_type get_source get_destination get_properties to_string)
);

