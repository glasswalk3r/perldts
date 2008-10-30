package DTS::Assignment::INI;

=head1 NAME

DTS::Assignment::INI - a class to represent a DTS DynamicPropertiesTaskAssignment object

=head1 SYNOPSIS

    use warnings;
    use strict;
    use DTS::Application;
    use Test::More;
    use XML::Simple;

    my $xml = XML::Simple->new();
    my $config = $xml->XMLin('test-config.xml');

    my $app = DTS::Application->new($config->{credential});

    my $package =
      $app->get_db_package(
        { id => '', version_id => '', name => $config->{package}, package_password => '' } );

	my $iterator = $package->get_dynamic_props();

    while ( my $dyn_prop = $iterator->() ) {

        foreach my $assignment_prop ( @{ $dyn_prop->get_properties } ) {

            if ( $assignment_prop->get_type eq 'INI' ) {

			    print $assignment_prop->to_string, "\n";

            }

        }
    }

=head1 DESCRIPTION

C<DTS::Assignment::INI> is a subclass of L<DTS::Assignment|DTS::Assignment> superclass. It represents
a DTS C<DynamicPropertiesTaskAssignment> object that has the properties C<SourceIniFileFileName>, C<SourceIniFileKey> 
and C<SourceIniFileSection> defined.

Unless you want to extend the C<DTS> API is quite probably that you're going to use C<DTS::Assignment::INI> 
returned by the C<get_properties> method from C<DTS::Task::DynamicProperty> class.

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use base qw(DTS::Assignment Class::Accessor);
use Hash::Util qw(lock_keys);

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(qw(filename section key));

our $VERSION = '0.02';

=head2 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    my $sibling = $self->get_sibling;

    $self->{filename} = $sibling->SourceIniFileFileName;
    $self->{section}  = $sibling->SourceIniFileSection;
    $self->{key}      = $sibling->SourceIniFileKey;

    lock_keys( %{$self} );

    return $self;

}

=head3 get_source

Overrided method from L<DTS::Assignment|DTS::Assignment> class. It will returns a result depending on the context
the method was invoked. in a scalar context, it will return a string with the results of the methods C<get_filename>,
C<get_section> and C<get_key> respectivally, separated by points and quoted with square brackets. In a list context, it
will return a list with the three values of the methods C<get_filename>, C<get_section> and C<get_keys>, in this order.

See L<DTS::Assignment|DTS::Assigment/get_destination> method for more information about how a property is setup using
a Dynamic Properties Task Assignment.

=cut

sub get_source {

    my $self = shift;

    return
      wantarray
      ? ( $self->get_filename, $self->get_section, $self->get_key )
      : '['
      . $self->get_filename . '].['
      . $self->get_section . '].['
      . $self->get_key . ']';

}

1;
__END__

=head3 get_filename

Returns a string with the complete pathname and filename of the INI files that will be read by the 
C<DTS::Assignment::INI> object.

=head3 get_section

Returns a string with the section of the INI file returned by the C<get_filename> method.

=head3 get_key

Returns a string with the key defined in the section returned by the C<get_section> method.

=head1 SEE ALSO

=over

=item *
L<DTS::Assignment> at C<perldoc>.

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
