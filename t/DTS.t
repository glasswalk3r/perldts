use Test::More tests => 2;
BEGIN { use_ok('DTS') }

can_ok(
    'DTS',
    qw(get_sibling
      is_sibling_ok
	  kill_sibling
	  debug)
);
