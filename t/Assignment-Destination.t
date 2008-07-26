use Test::More tests => 3;
use Test::Exception;

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

require DTS::Assignment::Destination;

