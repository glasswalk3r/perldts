package DTS::Package::Step;

=head1 NAME

DTS::Task - a Perl class to access Microsoft SQL Server 2000 DTS Package's steps 

=head1 SYNOPSIS

    use DTS::Package::Step;

=head1 DESCRIPTION

C<DTS::Package::Step> 

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use Carp qw(confess);
use base qw(DTS Class::Accessor);

__PACKAGE__->mk_ro_accessors(
    qw( start_time task_name script_lang activex add_global_vars description exec_result exec_status exec_time finish_time func_name)
);

our $VERSION = '0.01';

our %attrib_convertion = (
    start_time      => 'StartTime',
    task_name       => 'TaskName',
    script_lang     => 'ScriptLanguage',
    activex         => 'ActiveXScript',
    add_global_vars => 'AddGlobalVariables',
    close_conn      => 'CloseConnection',
    commit_success  => 'CommitSuccess',
    disable_step    => 'DisableStep',
    description     => 'Description',
    exec_result     => 'ExecutionResult',
    exec_status     => 'ExecutionStatus',
    exec_time       => 'ExecutionTime',
    finish_time     => 'FinishTime',
    func_name       => 'FunctionName'
);

# :TODO:10/8/2008:AFRJr:
# - all boolean properties must have get/set methods with descriptive names
# - time/date values must have proper Perl objects

=head2 METHODS

=head3 new

=cut

sub new {

    my $class   = shift;
    my $sibling = shift;

    my $self;

    foreach my $attrib ( keys(%attrib_convertion) ) {

        $self->{$attrib} = $sibling->{ $attrib_convertion{$attrib} };

    }

    $self->{_sibling} = $sibling;

    bless $self, $class;

    return $self;

}

=head3 is_disable 

Returns a string with the name of the task.

=cut

sub is_disable {

    my $self = shift;

    return $self->{disable_step};

}

=head3 disable_step

=cut

sub disable_step {

    my $self = shift;

    unless ( exists( $self->{_sibling} ) ) {

        confess $self->_error_message('DisableStep');

    }
    else {

        $self->{disable_step} = 1;
        $self->get_sibling()->{DisableStep} = 1;

    }

}

=head3 enable_step

=cut

sub enable_step {

    my $self = shift;

    unless ( exists( $self->{_sibling} ) ) {

        confess $self->_error_message('DisableStep');

    }
    else {

        $self->{disable_step} = 0;
        $self->get_sibling()->{DisableStep} = 0;

    }

}

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
      unless ( $self->get_sibling() );

    $self->{key} = $value;
    $self->get_sibling()->{ $attrib_convertion{$key} } = $value;

}

1;

__END__

=head1 SEE ALSO

=over

=item *
L<Win32::OLE> at C<perldoc>.

=item *
L<DTS::Package> at C<perldoc> to see how to fetch C<DTS::Task> objects.

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy, but one will need to convert examples written in VBScript to Perl code.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
