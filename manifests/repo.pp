# @summary
#   Create a rsync repository
#
class rsync::repo {

  include rsync::server

  $base = '/data/rsync'

  file { $base:
    ensure  => directory,
  }

  # setup default rsync repository
  rsync::server::module { 'repo':
    path    => $base,
    require => File[$base],
  }
}
