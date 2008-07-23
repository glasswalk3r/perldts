package DTS::Package;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(Class::Accessor DTS);
use DTS::TaskFactory;
use DTS::Connection;
use Win32::OLE qw(in);
use Win32::OLE::Variant;
use DateTime;
use Hash::Util qw(lock_keys);

# :WARNING:22/11/2006:ARFjr: this API is incomplete. There are much more properties defined in the
# SQL Server API

our $VERSION = '0.01';

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(
    qw(creation_date creator_computer description log_file max_steps name id priority version_id )
);

sub _init_creation_date {

    my $self              = shift;
    my $variant_timestamp = shift;

    $self->{creation_date} = DateTime->new(
        year   => $variant_timestamp->Date('yyyy'),
        month  => $variant_timestamp->Date('M'),
        day    => $variant_timestamp->Date('d'),
        hour   => $variant_timestamp->Time('H'),
        minute => $variant_timestamp->Time('m'),
        second => $variant_timestamp->Time('s'),
    );

}

sub log_to_server {

    my $self = shift;
    return $self->{log_to_server};

}

sub auto_commit {

    my $self = shift;
    return $self->{auto_commit};

}

sub new {

    my $class = shift;
    my $self = { _sibling => shift };

    bless $self, $class;

    $self->{auto_commit}      = $self->get_sibling->AutoCommitTransaction;
    $self->{creator_computer} = $self->get_sibling->CreatorComputerName;
    $self->{description}      = $self->get_sibling->Description;
    $self->{fail_on_error}    = $self->get_sibling->FailOnError;
    $self->{log_file}         = $self->get_sibling->LogFileName;
    $self->{max_steps}        = $self->get_sibling->MaxConcurrentSteps;
    $self->{name}             = $self->get_sibling->Name;
    $self->{id}               = $self->get_sibling->PackageID;
    $self->{version_id}       = $self->get_sibling->VersionID;
    $self->{nt_event_log} =
      $self->{_sibling}->WriteCompletionStatusToNTEventLog;

    $self->{log_to_server}        = $self->get_sibling->LogToSQLServer;
    $self->{explicit_global_vars} = $self->get_sibling->ExplicitGlobalVariables;

    $self->_set_lineage_opts();
    $self->_set_priority();

    $self->_init_creation_date( $self->get_sibling->CreationDate );

    lock_keys( %{$self} );

    return $self;

}

sub use_explicit_global_vars {

    my $self = shift;
    return $self->{explicit_global_vars};

}

sub use_event_log {

    my $self = shift;
    return $self->{nt_event_log};

}

sub fail_on_error {

    my $self = shift;
    return $self->{fail_on_error};

}

sub _set_priority {

    my $self         = shift;
    my $numeric_code = $self->get_sibling->PackagePriorityClass;

  CASE: {

        if ( $numeric_code == 3 ) {

            $self->{priority} = 'High';
            last CASE;

        }

        if ( $numeric_code == 1 ) {

            $self->{priority} = 'Low';
            last CASE;

        }

        if ( $numeric_code == 2 ) {

            $self->{priority} = 'Normal';
            last CASE;

        }

    }

}

sub _set_lineage_opts {

    my $self = shift;

    my $numeric_code = $self->get_sibling->LineageOptions;

    $self->{add_lineage_vars}       = 0;
    $self->{is_lineage_none}        = 0;
    $self->{is_repository}          = 0;
    $self->{is_repository_required} = 0;

# those values come from DTSLineageOptions in the DTS Programming MS SQL Server documentation
    $self->{add_lineage_vars}       = $numeric_code & 1;
    $self->{is_lineage_none}        = 1 if ( $numeric_code == 0 );
    $self->{is_repository}          = $numeric_code & 2;
    $self->{is_repository_required} = $numeric_code & 3;

}

sub add_lineage_vars {

    my $self = shift;
    return $self->{add_lineage_vars};

}

sub is_lineage_none {

    my $self = shift;
    return $self->{is_lineage_none};

}

sub is_repository {

    my $self = shift;
    return $self->{is_repository};

}

sub is_repository_required {

    my $self = shift;
    return $self->{is_repository_required};

}

sub to_string {

    my $self = shift;

    return "\tName: "
      . $self->get_name
      . "\n\tID: "
      . $self->get_id
      . "\n\tVersion ID: "
      . $self->get_version_id
      . "\n\tComputer where the package was created: "
      . $self->get_creator_computer
      . "\n\tDescription: "
      . $self->get_description
      . "\n\tExecution priority: "
      . $self->get_priority
      . "\n\tAuto commit enable? "
      . ( ( $self->auto_commit ) ? 'true' : 'false' )
      . "\n\tCreation date: "
      . $self->get_creation_date->datetime
      . "\n\tFail on error? "
      . ( ( $self->fail_on_error ) ? 'true' : 'false' )
      . "\n\tLog file: "
      . $self->get_log_file
      . "\n\tMaximum number of steps: "
      . $self->get_max_steps
      . "\n\tAdd lineage variables? "
      . ( ( $self->add_lineage_vars ) ? 'true' : 'false' )
      . "\n\tIs lineage none? "
      . ( ( $self->is_lineage_none ) ? 'true' : 'false' )
      . "\n\tWrite to repository if available? "
      . ( ( $self->is_repository ) ? 'true' : 'false' )
      . "\n\tWrite to repository is required? "
      . ( ( $self->is_repository_required ) ? 'true' : 'false' )
      . "\n\tLog to SQL Server? "
      . ( ( $self->log_to_server ) ? 'true' : 'false' )
      . "\n\tUse explicit global variables? "
      . ( ( $self->use_explicit_global_vars ) ? 'true' : 'false' )
      . "\n\tUse event log for logging? "
      . ( ( $self->use_event_log ) ? 'true' : 'false' );

}

sub get_connections {

    my $self = shift;
    my @connections_list;

    foreach my $connection ( in( $self->get_sibling->Connections ) ) {

        push( @connections_list, DTS::Connection->new($connection) );

    }

    return \@connections_list;

}

sub count_connections {

    my $self    = shift;
    my $counter = 0;

    foreach my $connection ( in( $self->get_sibling->Connections ) ) {

        $counter++;

    }

    return $counter;

}

sub get_tasks {

    my $self = shift;
    my @tasks_list;

    foreach my $task ( in( $self->get_sibling->Tasks ) ) {

        push( @tasks_list, DTS::TaskFactory::create($task) );

    }

    return \@tasks_list;

}

sub count_tasks {

    my $self    = shift;
    my $counter = 0;

    map { $counter++; } ( in( $self->get_sibling->Tasks ) );

    return $counter;

}

sub _get_tasks_by_type {

    my $self = shift;
    my $type = shift;
    my @items;

    foreach my $task ( in( $self->get_sibling->Tasks ) ) {

        next unless ( $task->CustomTaskID eq $type );
        push( @items, DTS::TaskFactory::create($task) );

    }

    return \@items;

}

sub _count_tasks_by_type {

    my $self    = shift;
    my $type    = shift;
    my $counter = 0;

    foreach my $task ( in( $self->get_sibling->Tasks ) ) {

        next unless ( $task->CustomTaskID eq $type );
        $counter++;

    }

    return $counter;

}

sub count_datapumps {

    my $self = shift;
    return $self->_count_tasks_by_type('DTSDataPumpTask');

}

sub get_datapumps {

    my $self = shift;
    return $self->_get_tasks_by_type('DTSDataPumpTask');

}

sub count_dynamic_props {

    my $self = shift;
    return $self->_count_tasks_by_type('DTSDynamicPropertiesTask');

}

sub get_dynamic_props {

    my $self = shift;
    return $self->_get_tasks_by_type('DTSDynamicPropertiesTask');

}

sub get_execute_pkgs {

    my $self = shift;
    return $self->_get_tasks_by_type('DTSExecutePackageTask');

}

sub count_execute_pkgs {

    my $self = shift;
    return $self->_count_tasks_by_type('DTSExecutePackageTask');

}

sub get_send_emails {
    my $self = shift;
    return $self->_get_tasks_by_type('DTSSendMailTask');

}

sub count_send_emails {

    my $self = shift;
    return $self->_count_tasks_by_type('DTSSendMailTask');

}

1;
__END__

=head1 NAME

DTS::Package - a Perl class to access Microsoft SQL Server 2000 DTS Packages 

=head1 SYNOPSIS

  use DTS::Package;

	# $OLE_package is an already instantied class using Win32::OLE
	my $package = DTS::Package->new( $OLE_package );

	# prints the custom task name
	print $custom_task->get_name, "\n";

=head1 DESCRIPTION

C<DTS::Package> is an class created to be used as a layer that represent a package object in DTS packages.
Although it's possible to use all features here by using only L<Win32::OLE|Win32::OLE> module, C<DTS::Package>
provides a much easier interface (pure Perl) and (hopefully) a better documentation.

=head2 EXPORT

None by default.

=head2 METHODS

=head3 new

Expects a DTS.Package2 object as a parameter and returns a new C<DTS::Package> object.

Not all properties from a DTS.Package2 will be available, specially the inner objects inside a DTS package will
be available only at execution of the respective methods. These methods may depend on the C<_sibling> attribute,
so one should not remove it before invoking those methods. The documentation tells where the method depends or
not on C<_sibling> attribute.

=head3 auto_commit

Returns true or false (in Perl terms, this means 1 or 0 respectivally) if the Auto Commit Transaction property is set.

=head3 get_creation_date

Returns a L<DataTime|DataTime> object with the timestamp of the creation date of the package. When used the
C<to_string> method, it will be returned the equivalent result of the method C<datetime> from L<DateTime|DateTime>
class.

The timezone of the L<DateTime|DateTime> object is the float one. See L<DateTime|DateTime/Floating DateTimes> for 
more information.

=head3 get_creator_computer

Returns a string with the machine name from where the package was created.

=head3 get_description

Returns a string with the description of the package.

=head3 get_log_file

Returns a string with the filename of the file used to store the log messages from the package execution.

=head3 get_max_steps

Returns a integer the maximum number of steps allowed to be executed simultaneously in the package.

=head3 get_name

Returns a string with the name of the package

=head3 get_id

Returns a string with the unique ID in the database of the package.

=head3 get_priority

Returns a string with the priority of the package ('High', 'Low' or 'Normal').

=head3 get_version_id

Returns a string with the version ID of the package.

=head3 add_lineage_vars

Returns true or false (1 or 0 respectivally) if the Add Lineage Variables property is set.

=head3 is_lineage_none

Returns true if provide no lineage (default) or false otherwise.

=head3 is_repository

Returns true or false if the package will write to Meta Data Services if available.

=head3 is_repository_required

Returns true or false if writing to Meta Data Services is required.

=head3 to_string

Returns a string will all properties from the package, separated with new line characters. Each property also has
a text with a sort description of the property.

This method will not fetch automatically the properties from objects inside the package, line connections and
tasks. Each object must be fetched first using the apropriated method and them invoking the C<to_string> from each
object.

=head3 get_connections

Returns an array reference with all connections objects available inside the package.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 count_connections

Return an integer that represents the total amount of connections available in the package object.

Besides the convenience, this method is uses less resources than invoking the respective C<get_> method and 
looping over the references in the array reference.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 get_tasks

Returns an array reference with all tasks available in the package.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

B<Warning:> C<get_tasks> method will abort with an error message if the DTS package has tasks that are not available
as subclasses of C<DTS::Task> class. In doubt, use the available methods to fetch only the supported tasks. This 
should be "fixed" in future releases with the implementation of the missing classes.

=head3 count_tasks

Returns a integer with the number of tasks available inside the package.

Besides the convenience, this method is uses less resources than invoking the respective C<get_> method and 
looping over the references in the array reference.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 count_datapumps

Returns an integer represents the total amount of C<DataPumpTask> tasks available in the package.

Besides the convenience, this method is uses less resources than invoking the respective C<get_> method and 
looping over the references in the array reference.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 get_datapumps

Returns an array reference with all the C<DataPumpTasks> tasks available in the package.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 count_dynamic_props

Returns an integer represents the total amount of C<DynamicPropertiesTask> tasks available in the package.

Besides the convenience, this method is uses less resources than invoking the respective C<get_> method and 
looping over the references in the array reference.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 get_dynamic_props

Returns an array reference with all the C<DynamicPropertiesTask> tasks available in the package.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 get_execute_pkgs

Returns an array reference with all the C<ExecutePackageTask> tasks available in the package.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 count_execute_pkgs

Returns an integer with the total of C<ExecutePackageTask> tasks available in the package.

Besides the convenience, this method is uses less resources than invoking the respective C<get_> method and 
looping over the references in the array reference.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 get_send_emails

Returns an array reference with all the C<SendMailTask> tasks available in the package.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head3 count_send_emails

Returns an integer with the total of C<SendMailTask> tasks available in the package.

Besides the convenience, this method is uses less resources than invoking the respective C<get_> method and 
looping over the references in the array reference.

This method depends on having the C<_sibling> attribute available, therefore is not possible to invoke this method
after invoking the C<kill_sibling> method.

=head1 SEE ALSO

=over

=item *
L<DTS::Application> at C<perldoc>. 

=item *
L<Win32::OLE> at C<perldoc>.

=item *
L<DateTime> and L<DateTime::TimeZone::Floating> at C<perldoc> for details about the implementation of 
C<creation_date> attribute.

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy, but you will need to convert examples written in VBScript to Perl code.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>glasswalk3r@yahoo.com.brE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
