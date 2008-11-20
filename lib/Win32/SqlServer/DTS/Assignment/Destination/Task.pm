package Win32::SqlServer::DTS::Assignment::Destination::Task;

=head1 NAME

Win32::SqlServer::DTS::Assignment::Destination::Task - a subclass of Win32::SqlServer::DTS::Assignment::Destination for tasks

=head1 SYNOPSIS

    use warnings;
    use strict;
    use Win32::SqlServer::DTS::Application;
    my $xml = XML::Simple->new();
    my $config = $xml->XMLin('test-config.xml');

    my $app = Win32::SqlServer::DTS::Application->new($config->{credential});

    my $package =
      $app->get_db_package(
        { id => '', version_id => '', name => $config->{package}, package_password => '' } );

	my $iterator = $package->get_dynamic_props();

    while ( my $dyn_prop = $iterator->() ) {

        my $assign_iterator = $dyn_props->get_assignments();

        while ( my $assignment = $assign_iterator->() ) {

            my $dest = $assignment->get_destination();

		# checking all properties global variables being handled by Dynamic Properties task
            if ( $dest->changes('Task') ) {

                print $dest->get_string(), "\n";

            }

        }

    }


=head1 DESCRIPTION

C<Win32::SqlServer::DTS::Assignment::Destination::GlobalVar> is a subclass of C<Win32::SqlServer::DTS::Assignment::Destination> and represents the 
tasks properties as the assignments destinations of a DTS package.

The string returned by the C<get_string> method has this format: 

C<'Tasks';name of the task;'Properties';name of the property>.

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use Carp qw(confess);
use base qw(Win32::SqlServer::DTS::Assignment::Destination);

our $VERSION = '0.01';

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(qw(taskname));

=head2 METHODS

=head3 initialize

C<initialize> method sets the I<destination> attribute as the DTS Package task property name. As an additional attribute,
the method also sets I<taskname> with the task name being targeted.

=cut

sub initialize {

    my $self = shift;

    my @values = split( /;/, $self->get_string() );

    $self->{destination} = $values[3];
    $self->{taskname}    = $values[1];

    confess "'destination' attribute cannot be undefined\n"
      unless ( defined( $self->{destination} ) );

    confess "'taskname' attribute cannot be undefined\n"
      unless ( defined( $self->{taskname} ) );

}

1;
__END__

=head1 SEE ALSO

=over

=item *
L<Win32::SqlServer::DTS::Assignment> at C<perldoc>.

=item *
L<Win32::SqlServer::DTS::Assignment::Destination> at C<perldoc>.

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy, but one will need to convert examples written in VBScript to Perl code.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
