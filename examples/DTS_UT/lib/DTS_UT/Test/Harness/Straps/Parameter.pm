package DTS_UT::Test::Harness::Straps::Parameter;

use base qw(Test::Harness::Straps);

#required for _wait2exit subroutine
eval { require POSIX; &POSIX::WEXITSTATUS(0) };
if ($@) {
    *_wait2exit = sub { $_[0] >> 8 };
}
else {
    *_wait2exit = sub { POSIX::WEXITSTATUS( $_[0] ) }
}

# overloading analyze_file from base class to accept parameters when calling
# the test file
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

1;
