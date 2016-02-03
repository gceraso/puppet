# Class to manage puppet client.
class puppet::client (
  $daemon_options = 'undef',
  $puppet_script = '/usr/local/bin/puppet-launcher.sh',
  $cron_minutes = [ 3, 8, 13, 18, 23, 28, 33, 38, 43, 48, 53, 58 ],
  $cron_hour   = '*',
  $puppet_client_version = hiera('puppet_client_version', 'installed'),
  $my_puppet_maxwait = hiera('my_puppet_maxwait', ''),
  $puppet_environment = hiera('puppet_environment', 'production'),
) {

  include puppet

  case $::puppet::runtype {
    'service': {
      $agent_ensure   = 'absent'
      $script_ensure  = 'absent'
      $service_ensure = true
    }
    'agent_cron': {
      $agent_ensure   = 'present'
      $script_ensure  = 'absent'
      $service_ensure = false
    }
    'script_cron': {
      $agent_ensure   = 'absent'
      $script_ensure  = 'present'
      $service_ensure = false
    }
    default: {
    }
  }


  package {
    'puppet-agent':
      ensure => $puppet_client_version;
  }

    file {
    'puppet-launcher-sh':
      ensure  => present,
      path    => '/usr/local/bin/puppet-launcher.sh',
      content => template('puppet/puppet-launcher.sh.erb'),
      owner   => 0,
      group   => 0,
      mode    => '0700';
  }

  cron {
    'run_puppet_agent':
      ensure  => $agent_ensure,
      command => 'puppet agent -t > /dev/null 2>&1',
      minute  => $cron_minutes,
      hour    => $cron_hour;
    'run_puppet_script':
      ensure  => $script_ensure,
      command => "${puppet_script} > /dev/null 2>&1",
      minute  => $cron_minutes,
      hour    => $cron_hour;
  }

  service { 'puppet':
    ensure  => $service_ensure,
    enable  => $service_ensure,
    require => Package['puppet-agent']
  }
}
