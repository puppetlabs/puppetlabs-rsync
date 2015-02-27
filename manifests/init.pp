# Class: rsync
#
# This module manages rsync
#
class rsync(
  $package_ensure    = 'installed',
  $manage_package    = true
) {

  if $manage_package {
    package { 'rsync':
      ensure => $package_ensure,
    } -> Rsync::Get<| |>
  }
}
