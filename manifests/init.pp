# Class: rsync
#
# This module manages rsync
#
class rsync(
  $package_ensure = 'installed',
  $execpath       = ['/opt/csw/bin','/usr/local/bin','/usr/bin','/bin'],
) {

  package { 'rsync':
    ensure => $package_ensure,
  } -> Rsync::Get<| |>
}
