package DTS::AssignmentFactory;

use 5.008008;
use strict;
use warnings;
use Carp;
use DTS::AssignmentTypes;

our $VERSION = '0.01';

sub create {

    my $assignment = $_[1];

    confess "Must received a valid assignment as a parameter\n"
      unless ( defined($assignment) );

    my $type = DTS::AssignmentTypes->get_class_name( $assignment->SourceType );

    # using DOS directory separator
    my $location  = 'DTS\\Assignment\\' . $type . '.pm';
    my $new_class = 'DTS::Assignment::' . $type;

    require $location;

    return $new_class->new($assignment);

}

1;

__END__

=head1 NAME

DTS::AssigmentFactory - a Perl abstract class to create DynamicPropertiesTaskAssignment objects

=head1 SYNOPSIS

    use DTS::Task::DynamicProperty;
    use DTS::AssignmentFactory;

    my $assignments = $dyn_props->get_sibling->Assignments;
    my @assigments;

    if ( defined($assignments) ) {

        foreach my $assignment ( in($assignments) ) {

            push( @assignments,
                DTS::AssignmentFactory->create($assignment) );

        }

        return \@assignments;

    } else {

        warn "This dynamic properties does not have any assignment\r\n";

    }

=head1 DESCRIPTION

C<DTS::AssignmentFactory> is a simple abstract actory to create L<DTS::Assignment|DTS::Assignment> objects.
This abstract class should be used only if one wants to extend the C<DTS> API.

=head2 EXPORT

None by default.

=head2 METHODS

=head3 create

Expects an DTS Assignment object as a parameter. Returns an L<DTS::Assignment|DTS::Assignment> object in a 
polymorphic way, depending on the DTS Assignment type.

=head1 SEE ALSO

=over

=item *
L<DTS::Assignment> at C<perldoc>, as well it's subclasses.

=item *
L<Win32::OLE> at C<perldoc>.

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy, but one will need to convert examples written in VBScript to Perl code.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>glasswalk3r@yahoo.com.brE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
