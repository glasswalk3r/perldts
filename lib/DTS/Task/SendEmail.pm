package DTS::Task::SendEmail;

use 5.008008;
use strict;
use warnings;
use Carp;
use base qw(DTS::Task Class::Accessor);
use Hash::Util qw(lock_keys);

our $VERSION = '0.01';

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(
    qw(message_text cc_line attachments profile_password profile subject to_line)
);

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    $self->{cc_line} = $self->get_sibling->Properties->Parent->CCLine;
    $self->{attachments} =
      $self->get_sibling->Properties->Parent->FileAttachments;
    $self->{message_text} = $self->get_sibling->Properties->Parent->MessageText;
    $self->{profile_password} =
      $self->get_sibling->Properties->Parent->Password;
    $self->{profile} = $self->get_sibling->Properties->Parent->Profile;
    $self->{save_sent} =
      $self->get_sibling->Properties->Parent->SaveMailInSentItemsFolder;
    $self->{is_nt_service} =
      $self->get_sibling->Properties->Parent->IsNTService;
    $self->{subject} = $self->get_sibling->Properties->Parent->Subject;
    $self->{to_line} = $self->get_sibling->Properties->Parent->ToLine;

    lock_keys( %{$self} );

    return $self;

}

sub is_nt_service {

    my $self = shift;
    return $self->{is_nt_service};

}

sub save_sent {

    my $self = shift;
    return $self->{save_sent};

}

sub get_properties {

    my $self = shift;

    return [
        $self->is_nt_service,    $self->save_sent,
        $self->get_message_text, $self->get_cc_line,
        $self->get_attachments,  $self->get_profile_password,
        $self->get_profile,      $self->get_subject,
        $self->get_to_line
    ];

}

sub to_string {

    my $self = shift;

    my $properties_string = "\tName: "
      . $self->get_name
      . "\r\n\tDescription: "
      . $self->get_description
      . "\r\n\tCC line: "
      . $self->get_cc_line
      . "\r\n\tAttachments: "
      . $self->get_attachments
      . "\r\n\tIs a NT service? "
      . ( ( $self->is_nt_service ) ? 'true' : 'false' )
      . "\r\n\tMessage:\r\n"
      . $self->get_message_text
      . "\r\n\tProfile password: "
      . $self->get_profile_password
      . "\r\n\tProfile: "
      . $self->get_profile
      . "\r\n\tSave message in sent folder? "
      . ( ( $self->save_sent ) ? 'true' : 'false' )
      . "\r\n\tSubject: "
      . $self->get_subject
      . "\r\n\tTo line: "
      . $self->get_to_line;

    return $properties_string;

}

1;

__END__

=head1 NAME

DTS::Task::SendEmail - a subclass of DTS::Task that represents a DTSSendMailTask object.

=head1 SYNOPSIS

    use warnings;
    use strict;
    use DTS::Application;
    use Test::More;
    use XML::Simple;

    my $xml    = XML::Simple->new();
    my $config = $xml->XMLin('test-config.xml');

    my $app = DTS::Application->new( $config->{credential} );

    my $package = $app->get_db_package(
        {
            id               => '',
            version_id       => '',
            name             => $config->{package},
            package_password => ''
        }
    );

    foreach my $send_mail ( @{ $package->get_send_emails } ) {

        print $send_mail->to_string, "\n";

    }


=head1 DESCRIPTION

C<DTS::Task::SendEmail> represents a DTS SendMail task object.

=head2 EXPORT

None by default.

=head2 METHODS

All methods from L<DTS::Task|DTS::Task> are also available.

=head3 is_nt_service

Returns true or false (1 or 0) whether the caller is a Microsoft Windows NT 4.0 or Microsoft Windows 2000 
Service. Returns true only if the program that calls the package Execute method is installed as a 
Windows NT 4.0 or Windows 2000 Service.

=head3 save_sent

Returns true or false (1 or 0) whether to save outgoing e-mail messages in the Sent Items folder.

=head3 get_message_text

Returns a string with the message text defined, including new line characters.

=head3 get_cc_line

Returns a string with the email addresses included in the I<CC> field of the email. Email are separated by semicolons.

=head3 get_attachments

Returns the complete pathname and filename of the attachments, separated by semicolons.

=head3 get_profile_password

Returns a string with the defined profile password, if used.

=head3 get_profile

Returns a string with the profile being used to send the email.

=head3 get_subject

Returns a string with the subject of the email

=head3 get_to_line

Returns a string with all email addresses defined in the I<To> field of the email. Addresses are separated by
semicolon characters.

=head3 get_properties

Returns an array reference. The values are returned in the following order below:

=over

=item 0 
is_nt_service

=item 1 
save_sent

=item 2
message_text

=item 3
cc_line

=item 4
attachments

=item 5
profile_password

=item 6
profile

=item 7
subject

=item 8
to_line

=back

=head1 SEE ALSO

=over

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
