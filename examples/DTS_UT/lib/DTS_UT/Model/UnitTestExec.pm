package DTS_UT::Model::UnitTestExec;

use DTS_UT::Test::Harness::Straps::Parameter;
use Config::YAML;
use Params::Validate qw(validate_pos :types);
use base qw(Class::Accessor);

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(qw(file));

sub new {

    validate_pos( @_, { type => SCALAR }, { type => SCALAR } );

    my $class = shift;
    my $self = { file => shift };

    bless $self, $class;

    return $self;

}

sub run_tests {

    validate_pos(
        @_,
        { type => HASHREF },
        { type => ARRAYREF },
        { type => SCALAR }
    );

    my $self     = shift;
    my $packages = shift;
    my $test     = shift;

    my $strap = DTS_UT::Test::Harness::Straps::Parameter->new();

    my @results;

    foreach my $package ( @{$packages} ) {

        my $results = $strap->analyze_file( $test, $package );

        if ( defined( $strap->{error} ) ) {

            die $strap->{error};

        }

        my @failed_tests;

        foreach my $test ( @{ $results->{details} } ) {

            push( @failed_tests, { test => $test->{name} } )
              unless ( $test->{ok} );

        }

        # :TRICKY:7/8/2008:arfreitas: could not find a better way to
        # catch errors when the script tests fails
        unless (( defined( $results->{ok} ) )
            and ( defined( $results->{max} ) ) )
        {

            die
              "It was not possible to test $package: invalid test results";

        }
        else {

            push(
                @results,
                {
                    package      => $package,
                    ok           => $results->{ok},
                    max          => $results->{max},
                    failed       => $results->{max} - $results->{ok},
                    failed_tests => \@failed_tests
                }
            );

        }

    }

    return \@results;

}

# returns array reference
sub read_dts_list {

    my $self = shift;

    my $yml = Config::YAML->new( config => $self->get_file() );
    my $list;

    eval {

        $list = $yml->get_packages();

    };

    if ($@) {

        die "Could not read configuration file. $@";

    }
    else {

        return $list;

    }

}

1;
