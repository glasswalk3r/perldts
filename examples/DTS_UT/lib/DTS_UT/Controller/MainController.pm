package DTS_UT::Controller::MainController;

use base qw(DTS_UT::Controller);
use DTS_UT::Model::UnitTestExec;

sub setup {

    my $self = shift;

    $self->tmpl_path( $self->config_param('templates_path') );
    $self->start_mode('start');
    $self->error_mode('show_error');
    $self->run_modes(
        {
            'start'     => 'list_packages',
            'error'     => 'show_error',
            'exec_test' => 'exec_test'
        }
    );

}

sub list_packages {

    my $self = shift;

    my $template = $self->load_tmpl( $self->config_param('index_template') );

    $model =
      DTS_UT::Model::UnitTestExec->new( $self->config_param('dts_list') );

    my @values;
    my $counter = 1;

    foreach my $package ( @{ $model->read_dts_list() } ) {

        push( @values, { ITEM => 'dts' . $counter, PACKAGE => $package } );
        $counter++;

    }

    $template->param(
        MYSELF        => $self->query()->url( -absolute => 1 ),
        PACKAGES_LIST => \@values
    );

    return $template->output();

}

sub show_error {

    my $self      = shift;
    my $error_msg = shift;

    my $template = $self->load_tmpl( $self->config_param('error_template') );

    $template->param( ERROR_MSG => $error_msg );

    return $template->output();

}

sub exec_test {

    my $self = shift;

    my $template = $self->load_tmpl( $self->config_param('result_template') );

    $model =
      DTS_UT::Model::UnitTestExec->new( $self->config_param('dts_list') );

    my $query = $self->query();
    my @packages;

    foreach my $param ( $query->param() ) {

        next unless $param =~ /^dts\d+/;
        push( @packages, $query->param($param) );

    }

    unless (@packages) {

        $self->show_error('No package was selected for testing!')

    }
    else {

        my $results;

        eval {
            $results =
              $model->run_tests( \@packages,
                $self->config_param('test_script_path') );
        };

        if ($@) {

            $self->show_error($@);

        }
        else {

            $template->param(
                RESULTS => $results,
                MYSELF  => $query->url( -absolute => 1 )
            );

            return $template->output();

        }

    }

}

1;
