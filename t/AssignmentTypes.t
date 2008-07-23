use Test::More;
BEGIN { use_ok('DTS::AssignmentTypes') }

my @valid_types = qw(INI Query GlobalVar EnvVar Constant DataFile);
my $total       = scalar(@valid_types) - 1;

# $total holds the exact number of array indexes, adding one more to compensate
plan tests => $total + 2;

can_ok( 'DTS::AssignmentTypes', qw(get_class_name) );

for ( my $counter = 0 ; $counter <= $total ; $counter++ ) {

    cmp_ok( DTS::AssignmentTypes->get_class_name($counter),
        'eq', $valid_types[$counter],
        "Convertion from $counter code to $valid_types[$counter]" );

}

