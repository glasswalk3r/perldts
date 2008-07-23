package DTS::Task::DataPump;

=head1 NAME

DTS::Task::DataPump - a Perl subclass of DTS::Task to represent a DTSDataPumpTask object

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

    foreach my $datapump ( @{ $package->get_datapumps } ) {

        print $datapump->to_string, "\n";

    }

=head1 DESCRIPTION

C<DTS::Task::DataPump> implements a convenient way to fetch properties from a DTS DataPumpTask Task object of a DTS
Package.

=head2 EXPORT

Nothing.

=cut

use 5.008008;
use strict;
use warnings;
use Carp qw(confess);
use base qw(DTS::Task Class::Accessor);
use Hash::Util qw(lock_keys);

our $VERSION = '0.02';

=head2 METHODS

=cut

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(
    qw(rows_complete use_identity_inserts rows_complete exception_file
      commit_size max_errors)
);


=head3 new

Overrided method from L<DTS::Task|DTS::Task> to define additional attributes during object creation. See
L<DTS::Task::new method|DTS::Task/new> for more information.

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    $self->{exception_qualifier} =
      $self->get_sibling->Properties->Parent->ExceptionFileTextQualifier;
    $self->{input_global_vars} =
      $self->get_sibling->Properties->Parent->InputGlobalVariableNames;
    $self->{rows_complete} =
      $self->get_sibling->Properties->Parent->RowsComplete;
    $self->{exception_file} =
      $self->get_sibling->Properties->Parent->ExceptionFileName;
    $self->{commit_size} =
      $self->get_sibling->Properties->Parent->InsertCommitSize;
    $self->{max_errors} =
      $self->get_sibling->Properties->Parent->MaximumErrorCount;
    $self->{use_fast_load} =
      $self->get_sibling->Properties->Parent->UseFastLoad;

# :TRICKY:12/12/2006:ARFjr: strange name for a property that appears with a different name in the DTS Designer
    $self->{always_commit} =
      $self->get_sibling->Properties->Parent->DataPumpOptions;

    $self->{use_identity_inserts} =
      $self->get_sibling->Properties->Parent->AllowIdentityInserts;

    $self->_get_fast_load_options;
    $self->_get_exception_file_options;

    lock_keys( %{$self} );

    return $self;

}

=head3 use_single_file_7

Returns true or false depending if errors, source, and destination exception rows are all written to a single ANSI file.

=cut

sub use_single_file_7 {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{single_file_7};

}

=head3 use_source_row_file

Returns true or false depending if source exception rows are written to the source exception file.

=cut

sub use_source_row_file {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{source_row_file};

}

=head3 use_error_file

Returns true or false if error rows are written to a error file.

=cut

sub use_error_file {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{overwrite};

}

=head3 overwrite_log_file

Returns true or false if data is overwritten, rather than appended, to file.

=cut

sub overwrite_log_file {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{overwrite};

}

=head3 abort_on_log_failure

Returns true or false if termination of the data pump if execution logging fails is enable.

=cut

sub abort_on_log_failure {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{abort_on_log_failure};

}

=head3 use_destination_row_file

Returns true or false if destination exception rows are written to the destination exception file.

=cut

sub use_destination_row_file {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{destination_row_file};

}

=head3 use_fast_load

Returns true or false if the use of the FastLoad option (where rows are processed in batches 
under a single transaction commit) is enabled.

=cut

sub use_fast_load {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{use_fast_load};

}

=head3 log_is_ansi

Returns true or false if the encoding of the log file is ANSI ASCII.

=cut

sub log_is_ansi {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{is_ansi};

}

=head3 log_is_OEM

Returns true or false if the encoding of the log file is OEM.

=cut

sub log_is_OEM {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{is_OEM};

}

=head3 log_is_unicode

Returns true or false if the encoding of the log file is Unicode (UTF-16LE).

=cut

sub log_is_unicode {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{is_unicode};

}

=head3 always_commit

Returns true or false if the C<DataPumpTask> task will commit all successful batches including the final 
batch, even if the data pump terminates. Use this option to support restartability.

Strange as it may seen, this is called as I<Always commit> options in the DTS designer application, but received
the name C<DataPumpOptions> property in the DTS API.

=cut

sub always_commit {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{always_commit};

}


sub _get_exception_file_options {

    my $self = shift;
    my $numeric_value =
      $self->get_sibling->Properties->Parent->ExceptionFileOptions;

#Constant                                Value           Description
#----------------------------------------------------------------------------------------------------------------------
#DTSExceptionFile_AbortOnRowLogFailure   8192 (x2000)    Terminate the data pump if execution logging fails.
#DTSExceptionFile_Ansi                   256 (x0100)     File type is ANSI (uses ANSI code page).
#DTSExceptionFile_DestRowFile            8               Destination exception rows are written to the
#                                                        destination exception file.
#DTSExceptionFile_ErrorFile              2               Error rows are written to the error file.
#DTSExceptionFile_OEM                    512 (x0200)     File type is OEM (uses OEM code page).
#DTSExceptionFile_Overwrite              4096 (x1000)    Data is overwritten, rather than appended, to file.
#DTSExceptionFile_SingleFile70           1               Errors, source, and destination exception rows are
#                                                        all written to a single ANSI file.
#DTSExceptionFile_SourceRowFile          4               Source exception rows are written to the source exception file.
#DTSExceptionFile_Unicode                1024 (x0400)    File type is Unicode.

    $self->{abort_on_log_failure} = 0;
    $self->{is_ansi}              = 0;
    $self->{destination_row_file} = 0;
    $self->{error_file}           = 0;
    $self->{is_OEM}               = 0;
    $self->{overwrite}            = 0;
    $self->{single_file_7}        = 0;
    $self->{source_row_file}      = 0;
    $self->{is_unicode}           = 0;

    if ( ( $numeric_value & 8192 ) == 8192 ) {

        $self->{abort_on_log_failure} = 1;

    }

    if ( ( $numeric_value & 256 ) == 256 ) {

        $self->{is_ansi} = 1;

    }

    if ( ( $numeric_value & 8 ) == 8 ) {

        $self->{destination_row_file} = 1;
    }

    if ( ( $numeric_value & 2 ) == 2 ) {

        $self->{error_file} = 1;
    }

    if ( ( $numeric_value & 512 ) == 512 ) {

        $self->{is_OEM} = 1;

    }
    if ( ( $numeric_value & 4096 ) == 4096 ) {
        $self->{overwrite} = 1;
    }

    if ( ( $numeric_value & 1 ) == 1 ) {

        $self->{single_file_7} = 1;

    }

    if ( ( $numeric_value & 4 ) == 4 ) {
        $self->{source_row_file} = 1;

    }

    if ( ( $numeric_value & 1024 ) == 1024 ) {
        $self->{is_unicode} = 1;

    }

    # from the documentation:
    # "Errors, source, and destination exception rows are
    # all written to a single ANSI file."
    # Forcing "is_ansi" property to true.

    $self->{is_ansi} = 1 if ( $self->{single_file_7} );
}

=head3 use_check_constraints

Returns true or false if the datapump will check for the constrainst of the table before inserting new rows.

=cut

sub use_check_constraints {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{check_constraints};

}

=head3 use_keep_nulls

Returns true or false if the datapump will insert will insert NULL values from the data source into the destination.

=cut

sub use_keep_nulls {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{keep_nulls};
}

=head3 use_lock_table

Returns true or false if the datapump will lock the entire table instead using lock by page.

=cut

sub use_lock_table {

    my ( $self, $write_attemp ) = shift;
    confess "This is a read only method\n" if ( defined($write_attemp) );

    return $self->{lock_table};
}

sub _get_fast_load_options {

#Constant                       Value    Description
#-----------------------------------------------------------------------------------
#DTSFastLoad_CheckConstraints   2        Check constraints (default).
#DTSFastLoad_Default            2        Specifies the default, same as check constraints
#DTSFastLoad_KeepNulls          1        Keep NULLs.
#DTSFastLoad_NoOptions          0        No options.
#DTSFastLoad_TableLock          4        Lock table.
    my $self         = shift;
    my $numeric_code = $self->get_sibling->Properties->Parent->FastLoadOptions;

    # sanity checking
    $self->{check_constraints} = 0;
    $self->{keep_nulls}        = 0;
    $self->{lock_table}        = 0;

  CHECK: {

        if ( $numeric_code == 0 ) {

            # do nothing, besides there is nothing to do anyway
            last CHECK;

        }

        if ( ( $numeric_code && 1 ) == 1 ) {

            $self->{keep_nulls} = 1;

        }

        if ( ( $numeric_code && 2 ) == 2 ) {

            $self->{check_constraints} = 1;

        }

        if ( ( $numeric_code && 4 ) == 4 ) {

            $self->{lock_table} = 1;

        }

    }

}

=head3 use_identity_inserts

Returns true or false if I<Identity inserts> will be used.

=cut

sub use_identity_inserts {

    my $self = shift;
    return $self->{use_identity_inserts};

}

=head3 to_string

Returns a string with all attributes from the datapump object, separated by new line characters and with a
short description of each attribute.

=cut

sub to_string {

    my $self = shift;

    my $properties_string =
        "Input global variables: "
      . $self->get_input_global_vars
      . "\r\n\tRows complete: "
      . $self->get_rows_complete
      . "\r\n\tAllow identity inserts? "
      . ( ( $self->use_identity_inserts ) ? 'true' : 'false' )
      . "\r\n\tUse fast load? "
      . ( ( $self->use_fast_load ) ? 'true' : 'false' )
      . "\r\n\tException file: "
      . $self->get_exception_file
      . "\r\n\tInsert commit size: "
      . $self->get_commit_size
      . "\r\n\tMaximum number of errors allowed: "
      . $self->get_max_errors
      . "\r\n\tUses Keep Nulls? "
      . ( ( $self->use_keep_nulls ) ? 'true' : 'false' )
      . "\r\n\tUses Lock Table? "
      . ( ( $self->use_lock_table ) ? 'true' : 'false' )
      . "\r\n\tUses Check Constraints? "
      . ( ( $self->use_check_constraints ) ? 'true' : 'false' )
      . "\r\n\tRows completed: "
      . $self->get_rows_complete
      . "\r\n\tUses single file on SQL 7 format? "
      . ( ( $self->use_single_file_7 ) ? 'true' : 'false' )
      . "\r\n\tUse source row file? "
      . ( ( $self->use_source_row_file ) ? 'true' : 'false' )
      . "\r\n\tUse error file? "
      . ( ( $self->use_error_file ) ? 'true' : 'false' )
      . "\r\n\tOverwrite log file? "
      . ( ( $self->overwrite_log_file ) ? 'true' : 'false' )
      . "\r\n\tAbort on logging failure? "
      . ( ( $self->abort_on_log_failure ) ? 'true' : 'false' )
      . "\r\n\tUse destination row file? "
      . ( ( $self->use_destination_row_file ) )
      . "\r\n\tLog encoding is ANSI ASCII? "
      . ( ( $self->log_is_ansi ) ? 'true' : 'false' )
      . "\r\n\tLog encoding is OEM? "
      . ( ( $self->log_is_OEM ) ? 'true' : 'false' )
      . "\r\n\tLog encoding is Unicode? "
      . ( ( $self->log_is_unicode ) ? 'true' : 'false' );

    return $properties_string;

}

=head3 get_input_global_vars

Returns a string or a list of Data Transformation Services (DTS) global variable names that are to be 
used as parameters in a query or created in a subpackage, depending on the context that the method is invoked.

The returned string is made of the global variable names separated by semi-colons characters.

=cut

sub get_input_global_vars {

    my $self = shift;

    if (wantarray) {

        my @list = split( /\;/, $self->{input_global_vars} );

        map { s/^\"//; s/\"$//; } @list;

        return \@list;

    }
    else {

        return $self->{input_global_vars};

    }

}

=head3 get_properties

Returns an array reference with the values of the attributes of a C<DTS::Task::DataPump> in the order 
as shown below:

=over

=item 0
use_single_file_7

=item 1
use_source_row_file

=item 2
use_error_file

=item 3
overwrite_log_file

=item 4
abort_on_log_failure

=item 5
use_destination_row_file

=item 6
use_fast_load

=item 7
log_is_ansi

=item 8
log_is_OEM

=item 9
log_is_unicode

=item 10
always_commit

=item 11
use_check_constraints

=item 12
use_keep_nulls

=item 13
use_lock_table

=item 14
use_identity_inserts

=item 15
get_input_global_vars 

=item 16
rows_complete

=item 17
exception_file

=item 18
commit_size

=item 19
max_errors

=back

=cut

sub get_properties {

    my $self = shift;
    return [
        $self->use_single_file_7,    $self->use_source_row_file,
        $self->use_error_file,       $self->overwrite_log_file,
        $self->abort_on_log_failure, $self->use_destination_row_file,
        $self->use_fast_load,        $self->log_is_ansi,
        $self->log_is_OEM,           $self->log_is_unicode,
        $self->always_commit,        $self->use_check_constraints,
        $self->use_keep_nulls,       $self->use_lock_table,
        $self->use_identity_inserts, $self->get_input_global_vars,
        $self->get_rows_complete,    $self->get_exception_file,
        $self->get_commit_size,      $self->get_max_errors
      ]

}

1;

__END__

=head3 get_rows_complete

Returns the number of source rows, including rows for which errors occurred, processed by the task 
or transformation set.

=head3 get_exception_file

Returns the file name path where exception rows are written.

=head3 get_commit_size

Returns the number of rows that are inserted in a single transaction when the FastLoad option is being used.

=head3 get_max_errors

Returns the maximum number of error rows before the data pump terminates.

=head2 CAVEATS

This class is incomplete. There are several properties not defined here that exists in the DTS API.

=head1 SEE ALSO

=over

=item *
L<DTS::Task>, the superclass from where C<DTS::Task::DataPump> inherits, at C<perldoc>.

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

