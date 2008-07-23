package DTS::AssignmentTypes;

=head1 NAME

DTS::AssigmentTypes - a Perl abstract class that knows all DynamicPropertiesTaskAssignment objects types.

=head1 SYNOPSIS

    use DTS::AssignmentTypes;

	# assuming that $assignment is a DTS Dynamic Property assignment object
	my $type = DTS::AssignmentTypes->get_class_name($assignment->SourceType);

=head1 DESCRIPTION

C<DTS::AssignmentTypes> is a simple abstract class that knows all existing types of DTS Dynamic Properties assignments
types and how to convert those types to DTS::Assignment subclasses names. 

This abstract class should be used only if one wants to extend the C<DTS> API.

=head2 EXPORT

None by default.

=cut

use 5.008008;
use strict;
use warnings;
use Carp qw(confess);

our $VERSION = '0.01';

=head2 METHODS

=head3 get_class_name

C<get_class_name> is an B<abstract method> that converts the numeric type code from DTS API constant 
C<DynamicPropertiesTaskSourceType> to a proper string that represents a subclass of C<DTS::Assignment> class.
Returns one of the following strings, depending on the numeric code received as a parameter:

=over

=item *
INI

=item *
Query

=item *
GlobalVar

=item *
EnvVar

=item *
Constant

=item *
DataFile

=back

The valid types are:

 Symbol                                             Value  Description
 ---------------------------------------------------------------------------------------------------------------
 DTSDynamicPropertiesSourceType_Constant              4    Source is a constant.
 DTSDynamicPropertiesSourceType_DataFile              5    Source is the contents of a data file.
 DTSDynamicPropertiesSourceType_EnvironmentVariable   3    Source is the value of a system environment variable.
 DTSDynamicPropertiesSourceType_GlobalVariable        2    Source is the value of a DTS global variable within
                                                           the package.
 DTSDynamicPropertiesSourceType_IniFile               0    Source is the value of a key within an .ini file.
 DTSDynamicPropertiesSourceType_Query                 1    Source is a value returned by an SQL query.

=cut

use constant CLASSES => qw(INI Query GlobalVar EnvVar Constant DataFile);

sub get_class_name {

    my $type_code = $_[1];

    if (    ( defined($type_code) )
        and ( $type_code =~ /^\d$/ )
        and ( $type_code <= scalar( @{ [CLASSES] } ) ) )
    {

        return (CLASSES)[$type_code];

    }
    else {

        confess "Invalid type code received: $type_code\n";

    }

}

1;

__END__

=head1 SEE ALSO

=over

=item *
L<DTS::Assignment> at C<perldoc>, as well it's subclasses.

=item *
L<DTS::AssignmentFactory> at C<perldoc> also uses the C<get_class_name> method.

=item *
L<Win32::OLE> at C<perldoc>.

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy, but one will need to convert examples written in VBScript to Perl code.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
