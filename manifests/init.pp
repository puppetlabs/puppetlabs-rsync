# Class: rsync
#
# This module manages rsync
#
class rsync(
  $package_ensure    = 'installed',
  $manage_package    = true,
  $puts              = {},
  $gets              = {},
) {

  if $manage_package {
    ensure_packages([ 'rsync' ],
      { ensure => $package_ensure, }
    )
    Package['rsync'] -> Rsync::Get<| |>
  }

  create_resources(rsync::put, $puts)
  create_resources(rsync::get, $gets)
}
