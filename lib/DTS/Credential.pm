package DTS::Credential;

use 5.008008;
use strict;
use warnings;
use Carp;
use Hash::Util qw(lock_keys);

our $VERSION = '0.01';

sub new {

    my $class = shift;
    my $self  = shift;

    unless ( $self->{use_trusted_connection} ) {

        unless (( exists( $self->{user} ) )
            and ( exists( $self->{password} ) ) )
        {

            croak
"Username and password cannot be NULL if trusted connection is not in use\n";

        }

        #creates the missing keys to avoid issues when invoking to_list method
    }
    else {

        $self->{user}     = '';
        $self->{password} = '';

    }

    if ( $self->{use_trusted_connection} ) {

        $self->{auth_code} = 256;

    }
    else {

        $self->{auth_code} = 0;

    }

    delete $self->{use_trusted_connection};

    bless $self, $class;
    lock_keys( %{$self} );
    return $self;

}

sub to_list {

    my $self = shift;
    return $self->{server}, $self->{user}, $self->{password},
      $self->{auth_code};

}

1;

__END__

=head1 NAME

DTS::Credential - credentials to authenticate against a MS SQL Server 2000

=head1 SYNOPSIS

    use DTS::Credential;

    # regular authentication method
    my $credential = DTS::Credential->new(
        {
            server                 => 'somedatabase',
            user                   => 'user',
            password               => 'password',
            use_trusted_connection => 0
        }
    );

    #trusted authentication mode

    my $credential2 =
      DTS::Credential->new(
        { server => 'somedatabase', use_trusted_connection => 1 } );

=head1 DESCRIPTION

C<DTS::Credential> implements the authentication scheme expected by MS SQL Server connection depending 
on the mode that will be used (regular authentication or trusted connection).

This class was created to be able to invoke the DTS Application C<LoadFromSQLServer> (and others) method in a polymorphic 
way, since these methods expect a lot of parameters given in the correct order (some parameters are even unused, but 
one must inform them anyway).

One should not need to use this class directly: it is used by the L<DTS::Application|DTS::Application> module and, if
you're using this class there is nothing to worry about authentication.

=head2 EXPORT

None by default.

=head2 METHODS

C<DTS::Credential> does not inherients from any superclass. This means that the methods available in L<DTS|DTS> are
not available.

=head3 new

This method creates a new C<DTS::Credential> object. A hash reference must be passed as a parameter 
(see L<SYNOPSIS|/SYNOPSIS> for examples).

Depending on the authentication method, C<user> and C<password> are necessary or not. The Trusted Connection does
not need such values, but the C<new> method will abort with an error if you pass no keys with the necessary values.

A C<DTS::Credential> object will have the following attributes:

=over

=item *
server

=item *
user

=item *
password

=item *
auth_code

=back

C<auth_code> is defined by the DTS Application object documentation to be defined as explained below:

=over

=item * 
Constant DTSSQLStgFlag_Default  = 0

=item *
Constant DTSSQLStgFlag_UseTrustedConnection = 256

=back


=head3 to_list

Returns all attributes of the object in a ordered list. This will be used during method invoking to authenticate
the request against the MS SQL Server. The list is returned in this order:

=over

=item 1
server

=item 2
user

=item 3
password

=item 4
auth_code

=back

=head1 SEE ALSO

=over

=item *
L<Win32::OLE> at C<perldoc>.

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy. You will need to convert examples written in VBScript to Perl code.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>glasswalk3r@yahoo.com.brE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
