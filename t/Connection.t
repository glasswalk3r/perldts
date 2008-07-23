use Test::More tests => 2;
BEGIN { use_ok('DTS::Connection') }

can_ok(
    'DTS::Connection',
    qw(new get_name get_description get_type get_datasource get_catalog get_id get_provider
      get_user get_password get_oledb to_string)
);
