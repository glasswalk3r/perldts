package DTS::TaskFactory;

=head1 NAME

DTS::TaskFactory - a Perl abstract class to create DTS Package Tasks in a polymorphic way 

=head1 SYNOPSIS

    use DTS::TaskFactory;

	# $task is a unknow DTS Task object
    my $new_task = DTS::TaskFactory::create($task);
    print $new_task->to_string, "\n";

=head1 DESCRIPTION

C<DTS::TaskFactory> creates C<DTS::Task> subclasses objects depending on the type of the DTS Package Task object
passed as a reference.

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use Carp;
use DTS::TaskTypes;

our $VERSION = '0.02';

=head2 METHODS

=head3 create

Expects a C<DTSTask> object passed as a parameter.

Returns a object from a subclass of C<DTS::Task> depending on the C<CustomTaskID> property from the C<Task>
object passed as a parameter.

=cut

sub create {

    my $task           = shift;
    my $type_converted = DTS::TaskTypes::convert( $task->CustomTaskID );

    if ( defined($type_converted) ) {

        # using DOS directory separator
        my $location  = 'DTS\\Task\\' . $type_converted . '.pm';
        my $new_class = 'DTS::Task::' . $type_converted;

        require $location;

        return $new_class->new( $task );

    }
    else {

        croak $task->CustomTaskID . ' is not a implemented DTS::Task subclass';

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
L<DTS::Task|DTS::Task> and it's subclasses modules at C<perldoc>.

=item *
L<DTS::TaskTypes> at C<perldoc>.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
