use warnings;
use strict;
use DTS::Application;
use Test::More;
use CGI;

my $dts_pkg  = 'Testing Example';
my $server   = 'foobar';
my $user     = 'user';
my $password = 'password';

# must fetch from Package get_connections and parse to retrieve only
# the flag file connections. This should be done before plan tests to
# be able to calculate how many tests will be executed
my @flat_file_conns;

my $app = DTS::Application->new(
    {
        server                 => $server,
        user                   => $user,
        password               => $password,
        use_trusted_connection => 0
    }
);

my $package =
  $app->get_db_package(
    { id => '', version_id => '', name => $dts, package_password => '' } );

fetch_flat_file_conns();

my $cgi          = CGI->new();
my $test_builder = Test::More->builder;
$test_builder->failure_output( \*STDOUT );

print $cgi->header, $cgi->start_html( -title => 'Unit testing DTS package' );

#print $package->to_string, "\n";
print $cgi->h2("Total planned tests for DTS \"$dts\": ");

plan tests => $package->count_connections + 6 + $package->count_execute_pkgs +
  ( $package->count_datapumps * 9 ) + ( ( scalar(@flat_file_conns) ) * 4 );

print $cgi->start_pre();

ok( !$package->log_to_server, 'Log to SQL Server should be disable' );
ok( defined( $package->get_log_file ), 'Log to flat file is enable' );
ok( !$package->use_event_log,
    'Write completation status on Event log should be disable' );
ok(
    $package->use_explicit_global_vars,
    'Global variable are explicit declared'
);
cmp_ok( $package->count_connections, '>=', 2,
    'Package must have at least two connections' );
cmp_ok( $package->count_datapumps, '>=', 1,
    'Package must have at least one datapump task' );

test_conn_auto_cfg();
test_datapumps();
test_execute_pkgs() if ( $package->count_execute_pkgs > 0 );
test_flat_file_conns();

print $cgi->end_pre();
print $cgi->end_html();

sub test_flat_file_conns {

    my $conn_name;

    foreach my $conn (@flat_file_conns) {

        $conn_name = 'Flat file connection "' . $conn->get_name . '"';

        foreach my $property ( @{ $conn->get_oledb_props } ) {

          CASE: {

                if ( $property->get_name eq 'Row Delimiter' ) {

                    is( $property->get_value, "\r\n",
                        "$conn_name row delimiter must be CRLF characters" );
                    last CASE;

                }

                if ( $property->get_name eq 'Text Qualifier' ) {

                    is( $property->get_value, '',
                        "$conn_name text qualifier should be empty" );
                    last CASE;

                }

                if ( $property->get_name eq 'Column Delimiter' ) {

                    is( $property->get_value, '|',
                        "$conn_name column delimiter must be a pipe character"
                    );
                    last CASE;

                }

                # this king of information should be encapsulated into an OLEDB
                # object. M$ system engineers sucks!
                # OEM: type = 4
                # UTF: type = 2
                # ASCII: type = 1
                if ( $property->get_name eq 'File Type' ) {

                    is( $property->get_value, 2,
                        "$conn_name file enconding must be UTF-16LE" );
                    last CASE;
                }

            }

        }

    }

}

sub fetch_flat_file_conns {

    foreach my $conn ( @{ $package->get_connections } ) {

        push( @flat_file_conns, $conn )
          if ( $conn->get_provider eq 'DTSFlatFile' );

    }

}

sub test_execute_pkgs {

    my $package_name;

    foreach my $execute_pkg ( @{ $package->get_execute_pkgs } ) {

        $package_name = 'Execute Package task "' . $execute_pkg->get_name . '"';
        is( $execute_pkg->get_package_id,
            '', "$package_name must have Package ID empty" );

    }

}

sub test_datapumps {

    foreach my $datapump ( @{ $package->get_datapumps } ) {

        my $datapump_name = 'Datapump "' . $datapump->get_name . '"';

        ok(
            defined( $datapump->get_exception_file ),
            "$datapump_name uses an exception file for logging"
        );
        ok( !$datapump->use_single_file_7,
            "$datapump_name does not use SQL 7 file format for logging" );
        ok(
            defined( $datapump->use_source_row_file ),
            "$datapump_name uses Source Row File logging"
        );
        ok(
            defined( $datapump->use_destination_row_file ),
            "$datapump_name uses Destination Row File logging"
        );

        ok( $datapump->use_fast_load,  "$datapump_name uses Fast Load" );
        ok( $datapump->use_keep_nulls, "$datapump_name uses Keep Nulls" );
        ok(
            $datapump->use_check_constraints,
            "$datapump_name uses Check Constraints"
        );
        ok( $datapump->always_commit,
            "$datapump_name uses Always Commit At Final Batch" );
        cmp_ok( $datapump->get_commit_size, '>=', 1000,
            "$datapump_name uses Insert Commit Size >= 1000" );
    }

}

sub test_conn_auto_cfg {

    my $conns_ref = fetch_conns( $package->get_connections );

    foreach my $dyn_prop ( @{ $package->get_dynamic_props } ) {

        foreach my $assignment_prop ( @{ $dyn_prop->get_properties } ) {

            if ( $assignment_prop->{type} eq 'INI' ) {

                my @destination = split( /;/, $assignment_prop->{destination} );

                if ( $destination[0] eq 'Connections' ) {

                    if ( exists( $conns_ref->{ $destination[1] } ) ) {

                        if (
                            $conns_ref->{ $destination[1] }->[0] eq 'SQLOLEDB' )
                        {

                          CASE: {

                                if ( $destination[3] eq 'Catalog' ) {

                                    $conns_ref->{ $destination[1] }->[2]
                                      ->{catalog} = 1;
                                    last CASE;

                                }

                                if ( $destination[3] eq 'DataSource' ) {

                                    $conns_ref->{ $destination[1] }->[2]
                                      ->{datasource} = 1;
                                    last CASE;

                                }

                                if ( $destination[3] eq 'UserID' ) {

                                    $conns_ref->{ $destination[1] }->[2]
                                      ->{userid} = 1;
                                    last CASE;

                                }

                                if ( $destination[3] eq 'Password' ) {

                                    $conns_ref->{ $destination[1] }->[2]
                                      ->{password} = 1;
                                    last CASE;

                                }

                            }

                            #expected to be only text file datasource
                        }
                        else {

                            if ( $destination[3] eq 'DataSource' ) {

                                $conns_ref->{ $destination[1] }->[1] = 1;

                            }

                        }

                    }

                }

            }

        }

    }

    foreach my $conn ( keys %{$conns_ref} ) {

        if ( $conns_ref->{$conn}->[0] eq 'SQLOLEDB' ) {

            map { $conns_ref->{$conn}->[1] += $_ }
              values( %{ $conns_ref->{$conn}->[2] } );

            # if does not summs 4, something is missing

            ( $conns_ref->{$conn}->[1] == 4 )
              ? ( $conns_ref->{$conn}->[1] = 1 )
              : ( $conns_ref->{$conn}->[1] = 0 );

            # else must be DTSFlatFile type
        }

        ok( $conns_ref->{$conn}->[1],
            "Connection \"$conn\" automatic configuration by INI reading" );

    }

}

sub fetch_conns {

    my $connections_ref = shift;
    my %conns;

    foreach my $conn ( @{$connections_ref} ) {

# array reference holds connection type and boolean value indication configuration or not
        $conns{ $conn->get_name } = [ $conn->get_provider, 0 ];

     # the connection type below must have four values configured by INI reading
     # index 1 will still hold boolean value
        if ( $conns{ $conn->get_name }->[0] eq 'SQLOLEBD' ) {

            $conns{ $conn->get_name }->[2] =
              { userid => 0, password => 0, datasource => 0, catalog => 0 }

        }

    }

    return \%conns;

}

