package DTS::Package::Step::Result;

=head1 NAME

DTS::Task - a Perl class to represent a DTS Package Step execution result.

=head1 SYNOPSIS

    use DTS::Package::Step::Result;

=head1 DESCRIPTION

C<DTS::Package::Step::Result> does not exists in the regular MS SQL Server DTS 2000 API. 

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use base qw(Class::Accessor);
use Carp qw(confess);

__PACKAGE__->mk_ro_accessors(qw(step_name error_code source description));

our $VERSION = '0.01';

=head2 METHODS

=head3 new

=cut

sub new {

    my $class = shift;
    my $self  = shift;

    bless $self, $class;

    return $self;

}

=head3 to_string

Returns a string describing the values of C<step_name>,  C<error_code>,  C<description> and C<is_success> attributes.

=cut

sub to_string {

    my $self = shift;

    return 'Step "'
      . $self->get_step_name()
      . '" has '
      . ( $self->is_success() )
      ? 'successed'
      : 'failed'
      . ' with the following conditions:'
      . "\nError code: "
      . $self->get_error_code()
      . "\nDescription: "
      . $self->get_description();

}

sub to_html {

}

sub to_xml {

}

sub is_success {

    my $self = shift;

    return $self->{is_success};

}

1;

__END__

=head1 SEE ALSO

=over

=item *
L<Win32::OLE> at C<perldoc>.

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy, but one will need to convert examples written in VBScript to Perl code.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
