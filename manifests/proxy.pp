define freeradius::proxy::realm (
  $realm,
  $strip       = false,
  $ensure      = present,
  $home_server = undef,
  $home_pool   = undef,
  $auth_pool   = undef,
  $pool        = undef,
  $ms_chap_auth = undef,
  $ms_chap_domain = undef,
  $ms_chap_strip = false,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  if($strip) {
    $strip_str = 'strip'
  }
  else {
    $strip_str = 'nostrip'
  }

  if($ms_chap_strip) {
    $ms_chap_strip_str = ', Strip-User-Name := Yes'
  }
  else {
    $ms_chap_strip_str = ''
  }
  
  file { "${fr_basepath}/proxy.d/realm_${realm}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/proxy_realm.conf.erb'),
    require => [File["${fr_basepath}/proxy.d"], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
  
  if($ms_chap_auth == 'ntlm_auth') {
    file { "${fr_basepath}/hints.d/hints_${realm}.conf":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'root',
      group   => $fr_group,
      content => template('freeradius/proxy_realm_hints.conf.erb'),
      require => [File["${fr_basepath}/hints.d"], Group[$fr_group]],
      notify  => Service[$fr_service],
    } 
  }
  if($ms_chap_auth == 'ldap') {
    file { "${fr_basepath}/users.d/users_${realm}.conf":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'root',
      group   => $fr_group,
      content => template('freeradius/proxy_realm_hints.conf.erb'),
      require => [File["${fr_basepath}/hints.d"], Group[$fr_group]],
      notify  => Service[$fr_service],
    } 
  } 

}





define freeradius::proxy::server (
  $name,
  $secret,
  $ipaddr = undef,
  $ipv6addr = undef,
  $virtual_server = undef,
  $type = "auth+acct",
  $port = 1812,
  $proto = 'udp',
  $response_window = 20,
  $zombie_period = 40,
  $revive_interval = 120,
  $status_check = "status-server",
  $check_interval = 30,
  $num_answers_to_alive = 3,

) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/proxy.d/server_${name}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/proxy_server.conf.erb'),
    require => [File["${fr_basepath}/proxy.d"], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
  
  if ( !($ipaddr or $ipv6addr) or ($ipaddr and $ipv6addr)) {
    if (!$virtual_server) {
      fail('You have to set virtual_server OR ipaddr OR ipv6addr')
    }
  }
  else {
    if ($virtual_server) {
      fail('You have to set virtual_server OR ipaddr OR ipv6addr')
    }
  }

  unless $type in ['auth', 'acct', 'auth+acct', 'coa'] {
    fail('$type has to be auth, acct, auth+acct or coa')
  } 
    unless $proto in ['udp', 'tcp'] {
    fail('$proto has to be udp or tcp')
  }
    unless $status_check in ['status-server', 'none', 'request'] {
    fail('$status_check has to be status-server, none or request')
  }
  unless is_integer($port) {
    fail('$port has to be an integer')
  } 
  unless is_integer($response_window) {
    fail('$response_window has to be an integer')
  }
  unless is_integer($zombie_period) {
    fail('$zombie_period has to be an integer')
  }
  unless is_integer($revive_interval) {
    fail('$revive_interval has to be an integer')
  }
  unless is_integer($check_interval) {
    fail('$check_interval has to be an integer')
  }
  unless is_integer($num_answers_to_alive) {
    fail('$num_answers_to_alive has to be an integer')
  }
}

define freeradius::proxy::pool (
  $name,
  $type = "fail-over",
  $home_server,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/proxy.d/pool_${name}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/proxy_pool.conf.erb'),
    require => [File["${fr_basepath}/proxy.d"], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
  unless $type in ['fail-over', 'load-balance', 'client-balance', 'client-port-balance', 'keyed-balance'] {
    fail("$type has to be 'fail-over', 'load-balance', 'client-balance', 'client-port-balance', 'keyed-balance'")
  } 

}

