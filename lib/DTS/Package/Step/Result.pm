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
use XML::Simple;
use Params::Validate qw(validate :types);

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_ro_accessors(
    qw(exec_status step_name error_code source description));

our $VERSION = '0.01';

=head2 METHODS

=head3 new

=cut

sub new {

    my $class = shift;

    validate(
        @_,
        {
            error_code  => { type => SCALAR },
            source      => { type => SCALAR },
            description => { type => SCALAR },
            step_name   => { type => SCALAR },
            is_success  => { type => SCALAR, regex => qr/[10]/ },
            exec_status => { type => SCALAR }
        }
    );

    my $self = shift;

    bless $self, $class;

    return $self;

}

=head3 to_string

Returns the C<DTS:Package::Step::Result> as a pure text content. Useful for simple reports.

=cut

sub to_string {

    my $self = shift;

    my @attrib_names = keys( %{$self} );

    foreach my $attrib_name (@attrib_names) {

        print "$attrib_name => $self->{$attrib_name}\n";

    }

}

=head3 to_xml

Returns the C<DTS:Package::Step::Result> as an XML content.

=cut

sub to_xml {

    my $self = shift;

    my $xs = XML::Simple->new();

    return $xs->XMLout($self);

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
C<DTS::Package::Step> documentation.

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
