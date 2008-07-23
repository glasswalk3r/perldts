use Test::More tests => 2;
BEGIN { use_ok('DTS::AssignmentFactory') }

can_ok( 'DTS::AssignmentFactory', qw(create) );

