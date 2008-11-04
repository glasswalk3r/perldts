package DTS_UT::Test::Harness::Straps::Parameter;

=pod

=head1 NAME

DTS_UT::Test::Harness::Straps::Parameter - subclass of C<Test::Harness::Straps> to accept line command parameters for
the test script.

=head1 DESCRIPTION

C<DTS_UT::Test::Harness::Straps::Parameter> will execute a test script by forking a new process, exactly 
C<Test::Harness::Straps> does, but it will accept and pass a parameter to the test script. The web application expects
to do that by passing the name of the DTS package to test.

DO NOT use it for web applications running in a Apache/mod_perl or IIS/PerlEz environment, were 
forking a new process from the server process itself is never a good idea for performance reasons. There are some issues
forking with IIS 5 with Perl.

C<DTS_UT::Test::Harness::Straps::Eval> is a hack from C<Test::Harness::Straps> module. Those modules are not maintained
anyore, so if you're taking serious about using it, my recomendation is that you check out L<TAP::Parser> module 
documentation.

=head1 EXPORT

Everything that C<Test::Harness::Straps> does.

=cut

use warnings;
use strict;

use base qw(Test::Harness::Straps);

#required for _wait2exit subroutine
eval { require POSIX; &POSIX::WEXITSTATUS(0) };
if ($@) {
    *_wait2exit = sub { $_[0] >> 8 };
}
else {
    *_wait2exit = sub { POSIX::WEXITSTATUS( $_[0] ) }
}

=head2 METHODS

=head3 analyze_file

Overloads C<analyze_file> from base class to accept parameters when calling the test file. The parameter should be
the DTS package name to test.

=cut 

sub analyze_file {

    my $self        = shift;
    my $file        = shift;
    my $dts_package = shift;

    unless ( -e $file ) {

        $self->{error} = "$file does not exist";
        return;

    }

    unless ( -r $file ) {

        $self->{error} = "$file is not readable";
        return;

    }

    local $ENV{PERL5LIB} = $self->_INC2PERL5LIB;

    if ($Test::Harness::Debug) {

        local $^W = 0;    # ignore undef warnings
        print "# PERL5LIB=$ENV{PERL5LIB}\n";

    }

    # *sigh* this breaks under taint, but open -| is unportable.
    my $line = $self->_command_line($file);

    $line .= ' "' . $dts_package . '"';

    unless ( open( FILE, "$line|" ) ) {

        print "can't run $file. $!\n";
        return;

    }

    my $results = $self->analyze_fh( $file, \*FILE );
    my $exit = close FILE;

    $results->set_wait($?);

    if ( $? && $self->{_is_vms} ) {

        eval q{use vmsish "status"; $results->set_exit($?); };

    }
    else {

        $results->set_exit( _wait2exit($?) );

    }

    $results->set_passing(0) unless $? == 0;

    $self->_restore_PERL5LIB();

    return $results;

}

=head1 SEE ALSO

=over

=item *
L<Test::Harness::Straps>

=item *
L<Test::More::Builder>

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
