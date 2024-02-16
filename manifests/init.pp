# @summary manage rsync
#
# @param package_ensure
#  ensure state of the rsync package
# @param manage_package
#  if true, manage the rsync package
# @param puts
#  create rsync::puts defined type resources
# @param gets
#  create rsync::gets defined type resources
#
class rsync (
  String $package_ensure = 'installed',
  Boolean $manage_package = true,
  Hash $puts = {},
  Hash $gets = {},
) {
  if $manage_package {
    package { 'rsync':
      ensure => $package_ensure,
    } -> Rsync::Get<| |>
  }

  create_resources(rsync::put, $puts)
  create_resources(rsync::get, $gets)
}
