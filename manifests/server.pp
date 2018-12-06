# Class: rsync::server
#
# The rsync server. Supports both standard rsync as well as rsync over ssh
#
# Requires:
#   class xinetd if use_xinetd is set to true
#   class rsync
#
class rsync::server(
  $use_xinetd   = true,
  $address      = '0.0.0.0',
  $address_ipv6 = '::',
  $motd_file    = 'UNSET',
  $use_chroot   = 'yes',
  $uid          = 'nobody',
  $gid          = 'nobody',
  $enable_ipv4  = true,
  $enable_ipv6  = false,
  $inetd_user   = 'root',
  $modules      = {},
) inherits rsync {

  case $facts['os']['family'] {
    'Debian': {
      $conf_file   = '/etc/rsyncd.conf'
      $servicename = 'rsync'
    }
    'Suse': {
      $conf_file   = '/etc/rsyncd.conf'
      $servicename = 'rsyncd'
    }
    'RedHat': {
      $conf_file   = '/etc/rsyncd.conf'
      $servicename = 'rsyncd'
    }
    'FreeBSD': {
      $conf_file   = '/usr/local/etc/rsync/rsyncd.conf'
      $servicename = 'rsyncd'
    }
    default: {
      $conf_file   = '/etc/rsync.conf'
      $servicename = 'rsync'
    }
  }


  if $use_xinetd {
    include ::xinetd
    if $enable_ipv4 {
      concat { $conf_file: }
      concat::fragment { 'rsyncd_conf_header':
        target  => $conf_file,
        content => template('rsync/header.erb'),
        order   => '00_header',
      }
      xinetd::service { 'rsync':
        bind         => $address,
        port         => '873',
        flags        => 'IPv4',
        server       => '/usr/bin/rsync',
        server_args  => "--daemon -4 --config=${conf_file}",
        user         => $inetd_user,
        service_name => $servicename,
        require      => Package['rsync'],
      }
    }
    if $enable_ipv6 {
      $conf_file_ipv6 = "${conf_file}_ipv6"
      concat { $conf_file_ipv6: }
      concat::fragment { 'rsyncd_ipv6_conf_header':
        target  => $conf_file_ipv6,
        content => template('rsync/header_ipv6.erb'),
        order   => '00_header',
      }
      xinetd::service { 'rsync-ipv6':
        bind         => $address_ipv6,
        port         => '873',
        flags        => 'IPv6',
        server       => '/usr/bin/rsync',
        server_args  => "--daemon -6 --config=${conf_file_ipv6}",
        user         => $inetd_user,
        service_name => $servicename,
        require      => Package['rsync'],
      }
    }
  } else {
    if $enable_ipv4 and $enable_ipv6 {
      fail('Please use xinetd to configure dual stack for rsync')
    }
    concat { $conf_file: }
    if $enable_ipv4 {
      concat::fragment { 'rsyncd_conf_header':
        target  => $conf_file,
        content => template('rsync/header.erb'),
        order   => '00_header',
      }
      service { $servicename:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        subscribe  => Concat[$conf_file],
      }
    }
    if $enable_ipv6 {
      $conf_file_ipv6 = $conf_file
      concat::fragment { 'rsyncd_conf_header':
        target  => $conf_file_ipv6,
        content => template('rsync/header_ipv6.erb'),
        order   => '00_header',
      }
      service { $servicename:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        subscribe  => Concat[$conf_file_ipv6],
      }
    }

    if ( $facts['os']['family'] == 'Debian' ) {
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


  # Template uses:
  # - $use_chroot
  # - $address
  # - $motd_file

  create_resources(rsync::server::module, $modules)

}
