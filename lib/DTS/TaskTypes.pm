package DTS::TaskTypes;

=head1 NAME

DTS::TaskTypes - a Perl abstract class to convert DTSTask types to DTS::Task types. 

=head1 SYNOPSIS

    use DTS::TaskTypes;

	# $task is a DTSTask object
    print DTS::TaskTypes::convert($task->CustomTaskID), "\n";

=head1 DESCRIPTION

C<DTS::TaskTypes> convert a value from the C<CustomTaskID> method from a C<DTSTask> object to the respective
type of a C<DTS::Task> object. Since the types names are not exactly the same, this abstract class is a helper
to convert those types based on a hardcoded hash table.

One should use this class only if intends to extend the C<DTS> API or create a factory.

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use Carp qw(cluck confess);

our $VERSION = '0.02';

=head2 METHODS

=head3 convert

Expects the string returned from the C<CustomTaskID> from a C<DTSTask> object. Returns a string with of the
respective C<DTS::Task>.

Beware that not all types of C<DTSTask> objects are implemented yet. The method will return C<undef> on those
cases.

Available types are

=over

=item *
DTSDataPumpTask

=item *
DTSDynamicPropertiesTask

=item *
DTSExecutePackageTask

=item *
DTSSendMailTask

=back

=cut

sub convert {

    my $type = shift;

    confess 'Type is an expected parameter' unless ( defined($type) );

    my %type_convertion = (

        DTSDataPumpTask          => 'DataPump',
        DTSDynamicPropertiesTask => 'DynamicProperty',
        DTSExecutePackageTask    => 'ExecutePackage',
        DTSSendMailTask          => 'SendEmail'
    );

    if ( exists( $type_convertion{$type} ) ) {

        return $type_convertion{$type};

    }
    else {

        cluck "type $type is unknow";

        #Unknow type;
        return undef;

    }

}

1;

__END__

=head1 SEE ALSO

=over

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy, but you will need to convert examples written in VBScript to Perl code.

=item *
L<DTS::Task|DTS::Task> and it's subclasses modules.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
