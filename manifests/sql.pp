# Configure SQL support for FreeRADIUS
define freeradius::sql (
  $database,
  $password,
  $server = 'localhost',
  $login = 'radius',
  $radius_db = 'radius',
  $num_sql_socks = '${thread[pool].max_servers}',
  $custom_query_file = '',
  $lifetime = '0',
  $max_queries = '0',
  $ensure = present,
  $acct_table1 = 'radacct',
  $acct_table2 = 'radacct',
  $postauth_table = 'radpostauth',
  $authcheck_table = 'radcheck',
  $authreply_table = 'radreply',
  $groupcheck_table = 'radgroupcheck',
  $groupreply_table = 'radgroupreply',
  $usergroup_table = 'radusergroup',
  $nas_table = 'nas',
  $read_groups = 'yes',
  $port = '3306',
  $readclients = 'no',
  $min = '4',
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  # Validate our inputs
  # Validate multiple choice options
  unless $database in ['mysql', 'mssql', 'oracle', 'postgresql'] {
    fail('$database must be one of mysql, mssql, oracle, postgresql')
  }

  # Hostnames
  unless (is_domain_name($server) or is_ip_address($server)) {
    fail('$server must be a valid hostname or IP address')
  }

  # Validate integers
  unless is_integer($port) {
    fail('$port must be an integer')
  }
  unless is_integer($min) {
    fail('$min must be an integer')
  }
  unless is_integer($lifetime) {
    fail('$lifetime must be an integer')
  }

  unless $read_groups in ['yes', 'no'] {
    fail('$read_groups must be yes or no')
  }
  unless $readclients in ['yes', 'no'] {
    fail('$readclients must be yes or no')
  }

  # Install custom query file
  if ($custom_query_file) {
    $query_file = "queries_${name}.conf"
    file { "${fr_basepath}/mods-config/sql/main/${database}/queries_${name}.conf":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'root',
      group   => $fr_group,
      source  => $custom_query_file,
      require => [Package[$fr_package], Group[$fr_group]],
      notify  => Service[$fr_service],
    }
  }
  else {
    $query_file = 'queries.conf'
  }

  # Generate a module config, based on sql.conf
  file { "${fr_basepath}/mods-enabled/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/modules/sql.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
