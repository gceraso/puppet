# For managing puppetserver
# TODO:
#   Manage gem installation
#   Manage config files and environments
#
class puppet::server (
  $puppet_server_version = hiera('puppet_server_version', 'installed'),
  $puppet_server_status = hiera('puppet_server_status', true),
  $daemon_options = 'undef',
){

include ::puppet


package {
  'puppetserver':
    ensure => $puppet_server_version;
}

  service { 'puppetserver':
    ensure  => $puppet_server_status,
    enable  => $puppet_server_status,
    require => Package['puppetserver']
  }

}
