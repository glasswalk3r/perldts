use Test::More tests => 2;

BEGIN { use_ok('DTS::Assignment::Destination') }

can_ok(
    'DTS::Assignment::Destination',
    qw(new
      initialize
      get_destination
      get_string
      get_raw_string
      set_string
      changes)
);

