use Test::More tests => 2;
BEGIN { use_ok('DTS::Task') }
can_ok( 'DTS::Task',
    qw(new get_name get_description get_type to_string ) );
