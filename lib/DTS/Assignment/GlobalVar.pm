package DTS::Assignment::GlobalVar;

=head1 NAME

DTS::Assignment::GlobalVar - a class to represent a DTS DynamicPropertiesTaskAssignment object

=head1 SYNOPSIS

    use warnings;
    use strict;
    use DTS::Application;
    use Test::More;
    use XML::Simple;

    my $xml = XML::Simple->new();
    my $config = $xml->XMLin('test-config.xml');

    my $app = DTS::Application->new($config->{credential});

    my $package = $app->get_db_package( { id               => '', version_id => '', 
                                          name             => $config->{package}, 
                                          package_password => '' } );

    my $iterator = $package->get_dynamic_props();

    while ( my $dyn_prop = $iterator->() ) {

        foreach my $assignment_prop ( @{ $dyn_prop->get_properties() } ) {

            if ( $assignment_prop->get_type() eq 'GlobalVar' ) {

			    print $assignment_prop->to_string(), "\n";

            }

        }
    }


=head1 DESCRIPTION

C<DTS::Assignment::GlobalVar> is a subclass of L<DTS::Assignment|DTS::Assignment> superclass. It represents
a DTS C<DynamicPropertiesTaskAssignment> object that has a C<SourceGlobalVariable> property defined.

Unless you want to extend the C<DTS> API is quite probably that you're going to use C<DTS::Assignment::GlobalVar> 
returned by the C<get_properties> method from C<DTS::Task::DynamicProperty> class.

=head2 EXPORT

None by default.

=cut

use 5.008008;
use strict;
use base qw(DTS::Assignment);
use Hash::Util qw(lock_keys);

our $VERSION = '0.02';

=head2 METHODS

Inherits all methods from C<DTS::Assignment>.

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    $self->{source} = $self->get_sibling->SourceGlobalVariable;

    lock_keys( %{$self} );

    return $self;

}

=head3 get_source

Overrided method from L<DTS::Assignment|DTS::Assignment> class. Returns a string with the name of a Data 
Transformation Services (DTS) package global variable that contains the value to which a package object 
property will be set by the DynamicPropertiesTask object. See 
L<DTS::Assignment|DTS::Assigment/get_destination> method for more information.

=cut

sub get_source {

    my $self = shift;
    return $self->{source};

}

1;
__END__

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
