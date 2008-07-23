package DTS::Assignment;

use 5.008008;
use strict;
use warnings;
use base qw(DTS);
use Carp qw(cluck confess);
use DTS::AssignmentTypes;

our $VERSION = '0.01';

sub new {

    my $class = shift;
    my $self = { _sibling => shift };

    bless $self, $class;

    my $sibling = $self->get_sibling;

    $self->{destination} = $sibling->DestinationPropertyID;
    $self->{destination} =~ tr/'//d;

    $self->{type} = $sibling->SourceType;

    return $self;

}

sub get_type {

    my $self = shift;
    return $self->{type};

}

sub get_type_name {

    my $self = shift;
    return DTS::AssignmentTypes->get_class_name( $self->get_type );

}

sub get_source {

    confess
"This method should be override by an specialized subclass of DTS::Assignment\n";

}

sub get_destination {

    my $self = shift;
    return
      wantarray ? split( /\;/, $self->{destination} ) : $self->{destination};

}

sub get_properties {

    my $self = shift;

    return {
        type        => $self->get_type,
        source      => scalar( $self->get_source ),
        destination => scalar( $self->get_destination )
      }

}

sub to_string {

    my $self = shift;

    return $self->get_type_name
      . " assignment\n"
      . 'Source: '
      . $self->get_source . "\n"
      . 'Destination: '
      . $self->get_destination . "\n";

}

1;

__END__

=head1 NAME

DTS::Assignment - a Perl base class to represent a DTS Dynamic Properties task Assignment object

=head1 SYNOPSIS

    package DTS::Assignment::SomethingWeird;
    use base (DTS::Assignment);

    #and goes on defining the child class

=head1 DESCRIPTION

C<DTS::Assignment> is a base class that should be inherited by a specialized class that defines one type of
Assignment object that is part of a DTS Dynamic Property task.

This class defines some common attributes that a subclass of C<DTS::Assignment>. Some methods must be override too,
and are explained in the next sections.

=head2 EXPORT

None by default.

=head2 METHODS

=head3 new

Instantiates a new C<DTS::Assigment> object.
Expects as parameter a C<DynamicPropertiesTaskAssignment> object. Unless you want to extend the 
C<DTS::Assignment> class, you will want to fetch C<DTS::Assignment> objects using the C<get_properties> 
method from L<DTS::Task::DynamicProperty|DTS::Task::DynamicProperty> class.

=head3 get_type

Returns the type as a numeric code for a instantied object of a subclass of C<DTS::Assignment>.

=head3 get_type_name

Returns a type as a string converted from the original numeric code using L<DTS::AssignmentTypes|DTS::AssignmentTypes>
abstract class to make the convertion.

=head3 get_source

This method should be override by any subclass of C<DTS::Assignment>. If invoked but not override, it will abort
with an error message.

=head3 get_destination

Returns a string with the destination property of an assignment object.

=head3 get_properties

Returns all properties from an assignment object as a hash reference, having the following keys:

=over

=item *
type

=item *
source

=item *
destination

=back

Since the method C<get_source> must be overrided by subclasses of C<DTS::Assingment> this method will failed
unless invoked thru one of those subclasses.

=head3 to_string 

Returns a string with the type, source and destination of an assignment. Useful for debugging or reporting.

=head1 SEE ALSO

=over

=item *
L<Win32::OLE> at C<perldoc>.

=item *
L<DTS::AssignmentFactory> at C<perldoc>.

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
