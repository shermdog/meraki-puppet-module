# Private class
class meraki::install {
  include resource_api::agent

  $gems = [ 'dashboard-api' ]

  package { $gems:
    ensure   => present,
    provider => 'puppet_gem',
  }
}
