package DTS::DateTime;

=head1 NAME

DTS::DateTime - DateTime Perl object built from Win32::OLE Variant values

=head1 SYNOPSIS

    use DTS::DateTime;

=head1 DESCRIPTION

Something

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use base qw(DateTime);
use Carp qw(confess);

our $VERSION = '0.01';

=head2 METHODS

=head3 new

=cut

sub new {

    my $class             = shift;
    my $variant_timestamp = shift;

    confess "Must receive an data Variant object as a parameter"
      unless ( $variant_timestamp->isa('Win32::OLE::Variant') );

    my $self = $class->SUPER::new(

        year   => $variant_timestamp->Date('yyyy'),
        month  => $variant_timestamp->Date('M'),
        day    => $variant_timestamp->Date('d'),
        hour   => $variant_timestamp->Time('H'),
        minute => $variant_timestamp->Time('m'),
        second => $variant_timestamp->Time('s'),
    );

    return $self;

}

1;

__END__

=head1 SEE ALSO

=over

=item *
MSDN on Microsoft website and MS SQL Server 2000 Books Online are a reference about using DTS'
object hierarchy, but you will need to convert examples written in VBScript to Perl code.

=item *
L<DTS::Task|DTS::Task> and it's subclasses modules.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut