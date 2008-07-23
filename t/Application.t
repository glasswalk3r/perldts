use Test::More tests => 4;
BEGIN { use_ok('DTS::Application') }

use DTS::Application;

my $dts_app = DTS::Application->new(
    {
        server                 => 'somedatabase',
        user                   => 'user',
        password               => 'password',
        use_trusted_connection => 0
    }
);

isa_ok( $dts_app, 'DTS::Application' );
can_ok( $dts_app,
    qw(get_db_package get_db_package_regex regex_pkgs_names list_pkgs_names get_credential)
);
isa_ok( $dts_app->get_credential, 'DTS::Credential' );

