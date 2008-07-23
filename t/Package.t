use Test::More tests => 2;
BEGIN { use_ok('DTS::Package') }

can_ok(
    'DTS::Package',
    qw(new auto_commit get_creation_date get_creator_computer get_description get_log_file get_max_steps
      get_name get_id get_priority get_version_id add_lineage_vars is_lineage_none is_repository is_repository_required
      to_string get_connections count_connections get_tasks count_datapumps get_datapumps count_dynamic_props
      get_dynamic_props get_execute_pkgs count_execute_pkgs get_send_emails count_send_emails )
);
