use Test::More tests => 2;
BEGIN { use_ok('DTS::TaskFactory') }
can_ok( 'DTS::TaskFactory', 'create' );
