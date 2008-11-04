package DTS_UT::Model::UnitTestExec;

=pod

=head1 NAME

DTS_UT::Model::UnitTestExec - model implementation for MVC architeture

=head1 DESCRIPTION

C<DTS_UT::Model::UnitTestExec> is a model of MVC implementation of L<CGI::Application>. It executes the unit tests
and returns the values.

=cut

use DTS_UT::Test::Harness::Straps::Parameter;
use Params::Validate qw(validate_pos :types);
use base qw(Class::Accessor);

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(qw(test_file));

=head2 EXPORTS

Nothing.

=head2 METHODS

=head3 new

Creates a new C<DTS_UT::Model::UnitTestExec> object.

Expects as a parameter the complete pathname of the test file it will run. Returns a C<DTS_UT::Model::UnitTestExec> 
object.

=cut

sub new {

    validate_pos( @_, { type => SCALAR }, { type => SCALAR } );

    my $class = shift;
    my $self = { test_file => shift};

    bless $self, $class;

    return $self;

}

=head3 run_tests

Execute the defined tests for one or more packages.

Expects as parameter an array reference with package(s) name(s) to test.

Returns an array reference with the following structure:

array reference -> [n] -> { 

	package      => package name
	ok           => tests that are OK
	max          => total number of tests executed
    failed       => total number of tests that failed
	failed_tests => array reference -> [n] = name of the test
	
}

=cut

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

=head1 SEE ALSO

=over

=item *
L<DTS_UT::Test::Harness::Straps::Parameter>

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
