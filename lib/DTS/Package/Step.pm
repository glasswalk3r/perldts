package DTS::Package::Step;

=head1 NAME

DTS::Step - a Perl class to access Microsoft SQL Server 2000 DTS Package's steps 

=head1 SYNOPSIS

    use DTS::Package::Step;

	# previously DTS::Package recovered
    my $steps   = $package->get_sibling()->Steps;

	foreach my $step ( in( $steps ) ) {

		my $new_step = DTS::Package::Step->new($step);
		print $new_step->get_exec_status(), "\n";

    }

=head1 DESCRIPTION

C<DTS::Package::Step> implements the DTS Package Step class in Perl. It implements all features of the original class, 
offering pure Perl interface with some additional methods to easy of use.

You probably will want to deal with this class internals only if you need to extended it or fix a bug. Otherwise, keep
to fetching C<DTS::Package::Step> objects directly from a C<DTS::Package> object.

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use base qw(DTS Class::Accessor);
use Carp qw(confess);
use Win32::OLE::Variant;
use DTS::Package::Step::Result;
use DTS::DateTime;

__PACKAGE__->mk_accessors(
    qw( name task_name script_lang activex add_global_vars description exec_result exec_status func_name)
);

__PACKAGE__->mk_ro_accessors(qw(start_time exec_time finish_time));

our $VERSION = '0.01';

our %attrib_convertion = (
    start_time         => 'StartTime',
    task_name          => 'TaskName',
    script_lang        => 'ScriptLanguage',
    activex            => 'ActiveXScript',
    add_global_vars    => 'AddGlobalVariables',
    close_conn         => 'CloseConnection',
    commit_success     => 'CommitSuccess',
    disable_step       => 'DisableStep',
    description        => 'Description',
    exec_result        => 'ExecutionResult',
    exec_status_code   => 'ExecutionStatus',
    exec_time          => 'ExecutionTime',
    finish_time        => 'FinishTime',
    func_name          => 'FunctionName',
    name               => 'Name',
    is_rowset_provider => 'IsPackageDSORowset',
    join_transaction   => 'JoinTransactionIfPresent',
    relative_priority  => 'RelativePriority',
    rollback_failure   => 'RollbackFailure'
);

our @exec_status;

$exec_status[4] = 'Step execution is completed.';
$exec_status[3] = 'Step execution is inactive.';
$exec_status[2] = 'Step execution is in progress.';
$exec_status[1] = 'Step is waiting to execute.';

our @relative_priority;

$relative_priority[4] = 'Above normal thread priority';
$relative_priority[2] = 'Below normal thread priority';
$relative_priority[5] = 'Highest thread priority';
$relative_priority[1] = 'Lowest thread priority';
$relative_priority[3] = 'Normal thread priority';

# :TODO:10/8/2008:AFRJr:
# - all boolean properties must have get/set methods with descriptive names

=head2 METHODS

=head3 new

Instantiates a new C<DTS::Package::Step> object. Expects as a parameter the original DTS Package Step.

Almost all attributes from the original objects (Step and Step2) were implement, except the Parent attribute. This class
has a hash that defines the convertion from the original attributes names to those implements in C<DTS::Package::Step>.
It's possible to check them out by looking at the C<%attrib_convertion> hash.

C<DTS::Package::Step> inherits all methods defined in the C<DTS> class.

=cut

sub new {

    my $class   = shift;
    my $sibling = shift;

    my $self;

    foreach my $attrib ( keys(%attrib_convertion) ) {

        # building DateTime objects with Variant date/time values
        if ( $attrib =~ /_time$/ ) {

            $self->{$attrib} =
              DTS::DateTime->new( $sibling->{ $attrib_convertion{$attrib} } );

            next;

        }

        $self->{$attrib} = $sibling->{ $attrib_convertion{$attrib} };

    }

    $self->{_sibling} = $sibling;

    bless $self, $class;

    return $self;

}

=head3 is_disable 

Returns true if the step is disabled or false otherwise.

=cut

sub is_disable {

    my $self = shift;

    return $self->{disable_step};

}

=head3 disable_step

Disables the step. 

Abort program execution if the C<_sibling> attribute is not defined.

=cut

sub disable_step {

    my $self = shift;

    unless ( $self->is_sibling_ok() ) {

        confess $self->_error_message('DisableStep');

    }
    else {

        $self->{disable_step} = 1;
        $self->get_sibling()->{DisableStep} = 1;

    }

}

=head3 enable_step

Enables the step. This changes the C<DTS::Package> object, that must have it's appropriate methods to save it's state
back to the server (or file).

Abort program execution if the C<_sibling> attribute is not defined.

=cut

sub enable_step {

    my $self = shift;

    unless ( $self->is_sibling_ok() ) {

        confess $self->_error_message('DisableStep');

    }
    else {

        $self->{disable_step} = 0;
        $self->get_sibling()->{DisableStep} = 0;

    }

}

=head3 _error_message

"Private" method. It expects a attribute name as a parameter (string) and returns a default error message when trying to
update the original Step object when the C<_sibling> attribute is not defined.

=cut

sub _error_message {

    my $self        = shift;
    my $attrib_name = shift;

    return
"Cannot update $attrib_name because there is no reference to the original DTS Step object";

}

# overriding Class::Accessor method to check for _sibling attribute
sub set {

    my $self  = shift;
    my $key   = shift;
    my $value = shift;

    confess $self->_error_message( $attrib_convertion{$key} )
      unless ( $self->is_sibling_ok() );

    $self->{key} = $value;
    $self->get_sibling()->{ $attrib_convertion{$key} } = $value;

}

=head3 get_exec_error_info

Same as GetExecutionErrorInfo method from the original DTS Step object.

Returns a C<DTS::Package::Step::Result> object. It will fail if the sibling object is not available.

=cut

sub get_exec_error_info {

    my $self = shift;

    confess
"Cannot execute get_exec_error_info without a reference to the original DTS Step object"
      unless ( $self->is_sibling_ok() );

    my $error_code  = Variant( VT_I4 | VT_BYREF,   '-1' );
    my $source      = Variant( VT_BSTR | VT_BYREF, '' );
    my $description = Variant( VT_BSTR | VT_BYREF, '' );

    $self->get_sibling()
      ->GetExecutionErrorInfo( $error_code, $source, $description );

    return DTS::Package::Step::Result->new(
        {
            error_code  => $error_code,
            source      => $source,
            description => $description,
            step_name   => $self->get_name(),
            is_success  => $self->get_exec_status()
        }
    );

}

=head3 get_exec_status

Returns a string telling the execution status instead of a numeric code as C<get_exec_status_code> does.

Convertion table was fetched from MSDN documentation and reproduced in the package C<@exec_status> array. 

=cut

sub get_exec_status {

    my $self = shift;

    return $exec_status[ $self->get_exec_status_code() ]->{description};

}

=head3 add_global_vars

Returns true if the property AddGlobalVariables is enabled, false otherwise.

=cut

sub add_global_vars {

    my $self = shift;

    return $self->{add_global_vars};

}

=head3 enable_global_vars

Enable the property AddGlobalVariables.

=cut

sub enable_global_vars {

    my $self = shift;

    unless ( $self->is_sibling_ok() ) {

        confess $self->_error_message('AddGlobalVariables');

    }
    else {

        $self->{add_global_vars} = 1;
        $self->get_sibling()->{AddGlobalVariables} = 1;

    }

}

=head3 disable_global_vars

Disable the property AddGlobalVariables.

=cut

sub disable_global_vars {

    my $self = shift;

    unless ( $self->is_sibling_ok() ) {

        confess $self->_error_message('AddGlobalVariables');

    }
    else {

        $self->{disable_global_vars} = 0;
        $self->get_sibling()->{AddGlobalVariables} = 0;

    }

}

=head3 close_conn

Returns true if the CloseConnection attribute is active, false otherwise.

=cut

sub close_conn {

    my $self = shift;

    return $self->{close_conn};

}

=head3 enable_close_conn

Enables the CloseConnection attribute.

=cut

sub enable_close_conn {

    my $self = shift;

    unless ( $self->is_sibling_ok() ) {

        confess $self->error_message('CloseConnection');

    }
    else {

        $self->{close_conn} = 1;
        $self->get_sibling()->{CloseConnection} = 1;

    }

}

=head3 disable_close_conn

Disables the CloseConnection attribute.

=cut

sub disable_close_conn {

    my $self = shift;

    unless ( $self->is_sibling_ok() ) {

        confess $self->error_message('CloseConnection');

    }
    else {

        $self->{close_conn} = 0;
        $self->get_sibling()->{CloseConnection} = 0;

    }

}

1;

__END__

=head1 CAVEATS

Any change to C<DTS::Package::Step> must be saved by using the proper methods in the C<DTS::Package> object or they
will be lost as soons as the Step object is eliminated by the garbage collector.

All methods that changes object state and needs to sincronize with the original DTS Package Step object will abort
program execution if the C<_sibling> attribute does not exists or does not have a valid value.

=head1 SEE ALSO

=over

=item *
L<Win32::OLE> at C<perldoc>.

=item *
L<DTS::Package> at C<perldoc> to see how to fetch C<DTS::Package::Step> objects.

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS' object hierarchy, but 
one will need to convert examples written in VBScript to Perl code. Specially, there is all attributes description 
there.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
