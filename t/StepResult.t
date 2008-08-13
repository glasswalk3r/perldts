use Test::More tests => 2;
BEGIN { use_ok('DTS::Package::Step::Result') }

can_ok(
    'DTS::Package::Step::Result',
    qw(new
      to_string
      to_xml)
);
