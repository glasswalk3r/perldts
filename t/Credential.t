use Test::More tests => 3;

BEGIN { use_ok('DTS::Credential') }
can_ok( 'DTS::Credential', qw(new to_list) );

require DTS::Credential;

my $credential = DTS::Credential->new(
    {
        server                 => 'somewhere',
        user                   => 'user',
        password               => 'password',
        use_trusted_connection => 0
    }
);

my @list = $credential->to_list();

is( scalar( @list ),
    4, 'to_list method returns 4 elements in a list' );
