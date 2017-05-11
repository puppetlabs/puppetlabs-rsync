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
  $port       = '873',
  $modules    = {},
) inherits rsync {

  $conf_file = $::osfamily ? {
    'Debian'  => '/etc/rsyncd.conf',
    'suse'    => '/etc/rsyncd.conf',
    'RedHat'  => '/etc/rsyncd.conf',
    'FreeBSD' => '/etc/rsyncd.conf',
    default   => '/usr/local/etc/rsync/rsyncd.conf',
  }
  $servicename = $::osfamily ? {
    'suse'    => 'rsyncd',
    'RedHat'  => 'rsyncd',
    'FreeBSD' => 'rsyncd',
    default   => 'rsync',
  }

  if $use_xinetd {
    include xinetd
    xinetd::service { 'rsync':
      bind        => $address,
      port        => $port,
      server      => '/usr/bin/rsync',
      server_args => "--daemon --config ${conf_file}",
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

    if ( $::osfamily == 'Debian' ) {
      file { '/etc/default/rsync':
        source => 'puppet:///modules/rsync/defaults',
        notify => Service['rsync'],
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
