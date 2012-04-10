# Definition: rsync::server::module
#
# sets up a rsync server
#
# Parameters:
#   $path            - path to data
#   $comment         - rsync comment
#   $motd            - file containing motd info
#   $read_only       - yes||no, defaults to yes
#   $write_only      - yes||no, defaults to no
#   $list            - yes||no, defaults to yes
#   $uid             - uid of rsync server, defaults to 0
#   $gid             - gid of rsync server, defaults to 0
#   $incoming_chmod  - incoming file mode, defaults to 0644
#   $outgoing_chmod  - outgoing file mode, defaults to 0644
#   $max_connections - maximum number of simultaneous connections allowed, defaults to 0
#   $lock_file       - file used to support the max connections parameter, defaults to /var/run/rsyncd.lock
#    only needed if max_connections > 0
#
# Actions:
#   sets up an rsync server
#
# Requires:
#   $path must be set
#
# Sample Usage:
#   # setup default rsync repository
#   rsync::server::module { 'repo':
#     path    => $base,
#     require => File[$base],
#   }
#
define rsync::server::module (
  $path,
  $comment         = undef,
  $motd            = undef,
  $read_only       = 'yes',
  $write_only      = 'no',
  $list            = 'yes',
  $uid             = '0',
  $gid             = '0',
  $incoming_chmod  = '0644',
  $outgoing_chmod  = '0644',
  $max_connections = '0',
  $lock_file       = '/var/run/rsyncd.lock')  {

  if $motd {
    file { "/etc/rsync-motd-${name}":
      source => "puppet:///modules/rsync/motd-${motd}",
    }
  }

  file { "${rsync::server::rsync_fragments}/frag-${name}":
    content => template('rsync/module.erb'),
    notify  => Exec['compile fragments'],
  }
}
