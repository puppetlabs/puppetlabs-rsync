# Class: rsync::server
#
# The rsync server. Supports both standard rsync as well as rsync over ssh
#
# Requires:
#   class xinetd if use_xinetd is set to true
#   class rsync
#
class rsync::server(
  $use_xinetd = true,
  $address    = '0.0.0.0',
  $motd_file  = 'UNSET',
  $use_chroot = 'yes',
  $uid        = 'nobody',
  $gid        = 'nobody',
  $nice       = '0',
  $ionice     = '2',
  $modules    = {},
) inherits rsync {

  case $::osfamily {
    'Debian': {
      $conf_file = '/etc/rsyncd.conf'
      $servicename = 'rsync'

      case $::operatingsystem {
        'Debian': {
          if $::operatingsystemmajrelease <= 7 {
            $initstyle = 'init'
          } else {
            $initstyle = 'systemd'
          }
        }
        'Ubuntu': {
          if $::lsbmajdistrelease <= 14 {
            $initstyle = 'upstart'
          } else {
            $initstyle = 'systemd'
          }
        }
        default: {
          $conf_file = '/etc/rsync.conf'
          $servicename = 'rsync'
          $initstyle = 'init'
        }
      }
    }
    'RedHat': {
      $conf_file = '/etc/rsyncd.conf'
      $servicename = 'rsyncd'

      if $::operatingsystemmajrelease <= 6 {
        $initstyle = 'init'
      } else {
        $initstyle = 'systemd'
      }
    }
    'suse': {
      $conf_file = '/etc/rsyncd.conf'
      $servicename = 'rsyncd'

      if $::lsbdistrelease <= 11 {
        $initstyle = 'init'
      } else {
        $initstyle = 'systemd'
      }
    }
    'FreeBSD': {
      $conf_file = '/usr/local/etc/rsync/rsyncd.conf'
      $servicename = 'rsyncd'
      $initstyle = 'bsd'
    }
    default: {
      $conf_file = '/etc/rsync.conf'
      $servicename = 'rsync'
      $initstyle = 'init'
    }
  }

  if $use_xinetd {
    include xinetd
    xinetd::service { 'rsync':
      bind        => $address,
      port        => '873',
      nice        => $nice,
      server      => '/usr/bin/ionice',
      server_args => "-c${ionice} /usr/bin/rsync --daemon --config ${conf_file}",
      require     => Package['rsync'],
    }
  } else {
    service { $servicename:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => Concat[$conf_file],
    }

    if $initstyle == 'systemd' {
      file { 'systemd_rsync_service_d':
        ensure => directory,
        path   => "/etc/systemd/system/${servicename}.service.d",
      }

      file { 'systemd_nice':
        path    => "/etc/systemd/system/${servicename}.service.d/nice.conf",
        content => "[Service]\nNice=${nice}",
        require => File['systemd_rsync_service_d'],
        notify  => Service[$servicename],
      }

      file { 'systemd_ionice':
        path    => "/etc/systemd/system/${servicename}.service.d/ionice.conf",
        content => "[Service]\nIOSchedulingClass=${ionice}",
        require => File['systemd_rsync_service_d'],
        notify  => Service[$servicename],
      }
    }

    if ( $::osfamily == 'Debian' ) {
      file { '/etc/default/rsync':
        content => template('rsync/defaults.erb'),
        notify  => Service['rsync'],
      }
    }
  }

  if $motd_file != 'UNSET' {
    file { '/etc/rsync-motd':
      source => 'puppet:///modules/rsync/motd',
    }
  }

  concat { $conf_file: }

  # Template uses:
  # - $use_chroot
  # - $address
  # - $motd_file
  concat::fragment { 'rsyncd_conf_header':
    target  => $conf_file,
    content => template('rsync/header.erb'),
    order   => '00_header',
  }

  create_resources(rsync::server::module, $modules)

}
