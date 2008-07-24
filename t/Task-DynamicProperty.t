use Test::More tests => 2;
BEGIN { use_ok('DTS::Task::DynamicProperty') }
can_ok( 'DTS::Task::DynamicProperty',
    qw(new get_name get_description get_type to_string ) );
