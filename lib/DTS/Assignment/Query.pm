package DTS::Assignment::Query;

use 5.008008;
use strict;
use warnings;
use base qw(DTS::Assignment Class::Accessor);
use Hash::Util qw(lock_keys);

our $VERSION = '0.01';

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(qw(connection_id query_sql));

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    my $sibling = $self->get_sibling;

    $self->{connection_id} = $sibling->SourceQueryConnectionID;
    $self->{query_sql}     = $sibling->SourceQuerySQL;

    lock_keys( %{$self} );

    return $self;

}

sub get_source {

    my $self = shift;
    return wantarray
      ? ( $self->get_connection_id, $self->get_query_sql )
      : '[' . $self->get_connection_id . '].[' . $self->get_query_sql . ']';

}

1;
__END__

=head1 NAME

DTS::Assignment::Query - a class to represent a DTS DynamicPropertiesTaskAssignment object

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

    foreach my $dyn_prop ( @{ $package->get_dynamic_props } ) {

        foreach my $assignment_prop ( @{ $dyn_prop->get_properties } ) {

            if ( $assignment_prop->get_type eq 'Query' ) {

			    print $assignment_prop->to_string, "\n";

            }

        }
    }


=head1 DESCRIPTION

C<DTS::Assignment::Query> is a subclass of L<DTS::Assignment|DTS::Assignment> superclass. It represents
a DTS C<DynamicPropertiesTaskAssignment> object that has the properties C<SourceQueryConnectionID> 
and C<SourceQuerySQL> defined.

Unless you want to extend the C<DTS> API is quite probably that you're going to use C<DTS::Assignment::Query> 
returned by the C<get_properties> method from C<DTS::Task::DynamicProperty> class.

=head2 EXPORT

None by default.

=head2 METHODS

=head3 get_connection_id

Returns a string with the ConnectionID property of a DTS Connection object.

=head3 get_query_sql

Returns a string with the SQL query defined. The string will be returned exactly how it was created, so don't blame
the API with the SQL is in a bad format.

=head3 get_source

Overrided method from L<DTS::Assignment|DTS::Assignment> class. It will returns a result depending on the context
the method was invoked. in a scalar context, it will return a string with the results of the methods C<get_connection_id>
 and C<get_query_sql> respectivally, separated by points and quoted with square brackets. In a list context, it
will return a list with the values of the methods C<get_connection_id> and C<get_query_sql>, in this order.

See L<DTS::Assignment|DTS::Assigment/get_destination> method for more information about how a property is setup using
a Dynamic Properties Task Assignment.

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

Alceu Rodrigues de Freitas Junior, E<lt>glasswalk3r@yahoo.com.brE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
