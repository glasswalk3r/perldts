use warnings;
use strict;
use Test::More;
use Config::YAML;
use Cwd;
use Memoize;
use DTS::Application;

my @flat_file_conns;

my $cgi_yml  = Config::YAML->new( config => $ENV{CGIAPP_CONFIG_FILE} );
my $yml_conf = Config::YAML->new( config => $cgi_yml->get_ut_config() );

my $app = DTS::Application->new(
    {
        server                 => $yml_conf->get_server(),
        use_trusted_connection => $yml_conf->get_use_trusted_connection()
    }
);

my $pkg_name = shift;

die "Cannot procede without a DTS package name\n" unless ( defined($pkg_name) );

my $package = $app->get_db_package(
    {
        id               => '',
        version_id       => '',
        name             => $pkg_name,
        package_password => ''
    }
);

fetch_flat_file_conns($package);

my $test_builder = Test::More->builder;
$test_builder->failure_output( \*STDOUT );

memoize('fetch_execute_pkgs');

plan tests => $package->count_connections() + 6 +
  ( $package->count_execute_pkgs() * 2 ) +
  ( $package->count_datapumps() * 8 ) +
  ( ( scalar(@flat_file_conns) ) * 4 ) + 1;

ok( !$package->log_to_server, 'Log to SQL Server should be disable' );
ok( defined( $package->get_log_file ), 'Log to flat file is enable' );
ok( !$package->use_event_log,
    'Write completion status on Event log should be disable' );
ok(
    $package->use_explicit_global_vars,
    'Global variable are explicit declared'
);
cmp_ok( $package->count_connections, '>=', 2,
    'Package must have at least two connections' );
cmp_ok( $package->count_datapumps, '>=', 1,
    'Package must have at least one datapump task' );

test_conn_auto_cfg($package);
test_datapumps($package);
test_execute_pkgs($package) if ( $package->count_execute_pkgs > 0 );
test_flat_file_conns($package);
test_exec_pkg_auto_conf($package);
test_pkg_log_auto_conf($package);

sub test_flat_file_conns {

    my $conn_name;

    foreach my $conn (@flat_file_conns) {

        $conn_name = 'Flat file connection "' . $conn->get_name() . '"';

        my $oledb = $conn->get_oledb();

        foreach my $prop_name ( keys( %{$oledb} ) ) {

          CASE: {

                if ( $oledb->{$prop_name}->{name} eq 'Row Delimiter' ) {

                    is( $oledb->{$prop_name}->{value},
                        "\r\n",
                        "$conn_name row delimiter must be CRLF characters" );
                    last CASE;

                }

                if ( $oledb->{$prop_name}->{name} eq 'Text Qualifier' ) {

                    is( $oledb->{$prop_name}->{value},
                        '', "$conn_name text qualifier should be empty" );
                    last CASE;

                }

                if ( $oledb->{$prop_name}->{name} eq 'Column Delimiter' ) {

                    is( $oledb->{$prop_name}->{value}, '|',
                        "$conn_name column delimiter must be a pipe character"
                    );
                    last CASE;

                }

                if ( $oledb->{$prop_name}->{name} eq 'File Type' ) {

                    is( $oledb->{$prop_name}->{value},
                        'ASCII', "$conn_name file enconding must be ASCII" );
                    last CASE;
                }

            }

        }

    }

}

sub fetch_flat_file_conns {

    my $package = shift;

    foreach my $conn ( @{ $package->get_connections } ) {

        push( @flat_file_conns, $conn )
          if ( $conn->get_provider eq 'DTSFlatFile' );

    }

}

sub fetch_execute_pkgs {

    my $package = shift;

    my @tasks_list;

    foreach my $exec_pkg ( @{ $package->get_execute_pkgs } ) {

        $exec_pkg->kill_sibling();
        push( @tasks_list, $exec_pkg );

    }

    return \@tasks_list;

}

sub test_execute_pkgs {

    my $package = shift;
    my $package_name;

    foreach my $execute_pkg ( @{ fetch_execute_pkgs($package) } ) {

        $package_name = 'Execute Package task "' . $execute_pkg->get_name . '"';
        is( $execute_pkg->get_package_id,
            '', "$package_name must have Package ID empty" );

    }

}

sub test_pkg_log_auto_conf {

    my $package       = shift;
    my $log_auto_conf = 0;

    foreach my $dyn_prop ( @{ $package->get_dynamic_props() } ) {

        my $assign_iterator = $dyn_prop->get_assignments();

        while ( my $assignment = $assign_iterator->() ) {

            my $target = $assignment->get_destination();

            $log_auto_conf = 1
              if ( $target->changes('Package')
                and ( $target->get_destination() eq 'LogFileName' ) );

        }

    }

    ok( $log_auto_conf, 'Package log file configuration is automatic' );

}

sub test_exec_pkg_auto_conf {

    my $package = shift;

    my $exec_pkg_list = fetch_execute_pkgs($package);

    my %exec_pkg_map;

    foreach my $exec_pkg ( @{$exec_pkg_list} ) {

        $exec_pkg_map{ $exec_pkg->get_name() } =
          { ServerName => 0, ServerPassword => 0, ServerUserName => 0 };

    }

    undef $exec_pkg_list;

    foreach my $dyn_prop ( @{ $package->get_dynamic_props() } ) {

        my $assign_iterator = $dyn_prop->get_assignments();

        while ( my $assignment = $assign_iterator->() ) {

            my $target = $assignment->get_destination();

            if ( $target->changes('Task') ) {

                if ( exists( $exec_pkg_map{ $target->get_taskname() } ) ) {

                  CASE: {

                        my $name = $target->get_taskname();
                        my $dest = $target->get_destination();

                        if ( $dest eq 'ServerName' ) {

                            $exec_pkg_map{$name}->{ServerName} = 1;
                            last CASE;

                        }

                        if ( $dest eq 'ServerPassword' ) {

                            $exec_pkg_map{$name}->{ServerPassword} = 1;
                            last CASE;
                        }

                        if ( $dest eq 'ServerUserName' ) {

                            $exec_pkg_map{$name}->{ServerUserName} = 1;
                            last CASE;

                        }

                    }

                }

            }

        }

    }

    foreach my $exec_pkg ( keys(%exec_pkg_map) ) {

        my $total;
        map { $total += $_; } ( values( %{ $exec_pkg_map{$exec_pkg} } ) );

        is( $total, 3,
                'Auto configuration is done for '
              . $exec_pkg
              . ' Execute Package task' );

    }

}

sub test_datapumps {

    my $package = shift;

    foreach my $datapump ( @{ $package->get_datapumps() } ) {

        $datapump->kill_sibling();

        my $datapump_name = 'Datapump "' . $datapump->get_name() . '"';

        ok(
            (
                defined( $datapump->get_exception_file() )
                  and ( $datapump->get_exception_file() ne '' )
            ),
            $datapump_name . ' uses an exception file for logging'
        );
        ok( !$datapump->use_single_file_7(),
            $datapump_name
              . ' does not use SQL 7 file format for logging (warning)' );
        ok( defined( $datapump->use_source_row_file() ),
            $datapump_name . ' uses Source Row File logging (warning)' );
        ok( defined( $datapump->use_destination_row_file() ),
            $datapump_name . ' uses Destination Row File logging (warning)' );

        ok( $datapump->use_fast_load(),
            $datapump_name . ' uses Fast Load (warning)' );
        ok( $datapump->use_check_constraints(),
            $datapump_name . ' uses Check Constraints (warning)' );
        ok( $datapump->always_commit(),
            $datapump_name . ' uses Always Commit At Final Batch (warning)' );
        cmp_ok( $datapump->get_commit_size(),
            '>=', 1000,
            $datapump_name . ' uses Insert Commit Size >= 1000 (warning)' );

    }

}

sub test_conn_auto_cfg {

    my $package = shift;

    my $conns_ref = fetch_conns( $package->get_connections() );

    foreach my $dyn_prop ( @{ $package->get_dynamic_props } ) {

        my $assign_iterator = $dyn_prop->get_assignments();

        while ( my $assignment = $assign_iterator->() ) {

            my $target = $assignment->get_destination();

            if ( $target->changes('Connection') ) {

                if ( exists( $conns_ref->{ $target->get_conn_name() } ) ) {

                    if ( $conns_ref->{ $target->get_conn_name() }->[0] eq
                        'SQLOLEDB' )
                    {

                      CASE: {

                            my $dest = $target->get_destination();
                            my $name = $target->get_conn_name();

                            if ( $dest eq 'Catalog' ) {

                                $conns_ref->{$name}->[2]->{catalog} = 1;
                                last CASE;

                            }

                            if ( $dest eq 'DataSource' ) {

                                $conns_ref->{$name}->[2]->{datasource} = 1;
                                last CASE;

                            }

                            if ( $dest eq 'UserID' ) {

                                $conns_ref->{$name}->[2]->{userid} = 1;
                                last CASE;

                            }

                            if ( $dest eq 'Password' ) {

                                $conns_ref->{$name}->[2]->{password} = 1;
                                last CASE;

                            }

                        }

                    }
                    else {

                        if ( $target->get_destination() eq 'DataSource' ) {

                            $conns_ref->{ $target->get_conn_name() }->[1] = 1;

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

            ( $conns_ref->{$conn}->[1] == 4 )
              ? ( $conns_ref->{$conn}->[1] = 1 )
              : ( $conns_ref->{$conn}->[1] = 0 );

        }

        ok( $conns_ref->{$conn}->[1],
"Connection \"$conn\" automatic configuration done by a Dynamic Property task"
        );

    }

}

sub fetch_conns {

    my $connections_ref = shift;
    my %conns;

    foreach my $conn ( @{$connections_ref} ) {

        $conns{ $conn->get_name } = [ $conn->get_provider, 0 ];

        if ( $conns{ $conn->get_name }->[0] eq 'SQLOLEBD' ) {

            $conns{ $conn->get_name }->[2] =
              { userid => 0, password => 0, datasource => 0, catalog => 0 }

        }

    }

    return \%conns;

}

