# Class: rsync::repo
#
# This module creates a rsync repository
#
# Requires:
#   class rsync::server
#
class rsync::repo {

    include rsync::server

    $base = "/data/rsync"

    file { "$base":
        ensure  => directory,
    } # file

    # setup default rsync repository
    rsync::server::module{ "repo":
        path    => $base,
        require => File["$base"],
    } # rsync::server::module
} # class rsync::repo
