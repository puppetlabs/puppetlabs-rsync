# @sumnmary
#   The rsync server. Supports both standard rsync as well as rsync over ssh
#
# @param use_xinetd
#   use xinetd. If true the xinetd class is required.
# @param address
#   the address to bind
# @param motd_file
#   message of the day to display to clients on each connet.
#   use 'UNSET' to disable the message
# @param pid_file
#   path of the pid file. Use 'UNSET' to disable pid file
# @use_chroot
#   chroot to the path before starting the file transfer
# @param uid
#   user name or user id that file transfers to and from
# @param gid
#   group name or group id that file transfers to and from
# @param modules
#   create rsync::server::module defined type resources
# @param package_name
#   name of the rsync server package
# @param conf_file
#   path to the config file
# @param servicename
#   name of the rsync server service
# @param service_ensure
#   ensure status of the rsync server service
# @param service_enable
#   enable the rsync server service
# @param manage_package
#   manage the rsync server package
#
class rsync::server (
  Boolean $use_xinetd = true,
  String[1] $address = '0.0.0.0',
  String[1] $motd_file = 'UNSET',
  Variant[Enum['UNSET'], Stdlib::Absolutepath] $pid_file = '/var/run/rsyncd.pid',
  Boolean $use_chroot = true,
  String[1] $uid = 'nobody',
  String[1] $gid = 'nobody',
  Hash $modules = {},
  Optional[String[1]] $package_name = undef,
  Stdlib::Absolutepath $conf_file = '/etc/rsync.conf',
  String[1] $servicename = 'rsync',
  Stdlib::Ensure::Service $service_ensure = 'running',
  Variant[Boolean, Enum['mask']] $service_enable = true,
  Boolean $manage_package = $rsync::manage_package,
) inherits rsync {
  if $use_xinetd {
    include xinetd
    xinetd::service { 'rsync':
      bind        => $address,
      port        => '873',
      server      => '/usr/bin/rsync',
      server_args => "--daemon --config ${conf_file}",
      require     => Package['rsync'],
    }
  } else {
    # Manage the installation of the rsyncd package?
    if $manage_package {
      # RHEL8 and newer (and their variants) have a separate package for rsyncd daemon.  If the $package_name
      # variable is defined (the variable is defined in the hiera hierarchy), then install the package.
      if $package_name {
        package { $package_name:
          ensure => $rsync::package_ensure,
          notify => Service[$servicename],
        }
      }
    }

    service { $servicename:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => Concat[$conf_file],
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
