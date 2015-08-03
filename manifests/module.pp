# Install FreeRADIUS modules
define freeradius::module (
  $source = undef,
  $config = undef,
  $content = undef,
  $ensure = present,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/mods-enabled/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $content,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  if $config {
  file { "${fr_basepath}/mods-config/${name}":
    ensure  => $ensure,
    mode    => '0750',
    owner   => 'root',
    group   => $fr_group,
    source  => $config,
    content => $content,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
    recurse => true,
  }
  }

}
