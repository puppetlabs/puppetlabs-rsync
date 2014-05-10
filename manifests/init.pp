# Class: rsync
#
# This module manages rsync
#
class rsync($package_ensure = 'installed') {

  package { 'rsync':
    ensure => $ensure,
  } -> Rsync::Get<| |>
}
