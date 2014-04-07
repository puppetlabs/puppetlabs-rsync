# Class: rsync
#
# This module manages rsync
#
class rsync($ensure = 'installed') {

  package { 'rsync':
    ensure => $ensure,
  } -> Rsync::Get<| |>
}
