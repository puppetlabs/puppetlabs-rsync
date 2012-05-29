# Definition: rsync::server::module
#
# sets up a rsync server
#
# Parameters:
#   $path            - path to data
#   $comment         - rsync comment
#   $read_only       - true||false, defaults to true
#   $write_only      - true||false, defaults to false
#   $list            - true||false, defaults to true
#   $uid             - uid of rsync server, defaults to 0
#   $gid             - gid of rsync server, defaults to 0
#   $incoming_chmod  - incoming file mode, defaults to 0644, can be set to false
#   $outgoing_chmod  - outgoing file mode, defaults to 0644, can be set to false
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
  $read_only       = true,
  $write_only      = false,
  $list            = true,
  $uid             = '0',
  $gid             = '0',
  $incoming_chmod  = '0644',
  $outgoing_chmod  = '0644',
  $max_connections = '0',
  $lock_file       = '/var/run/rsyncd.lock'
) {

  # Converting booleans to yes/no.
  $read_only_real = $read_only ? { true  => 'yes', false => 'no', }
  $write_only_real = $write_only ? { true  => 'yes', false => 'no', }
  $list_real = $list ? { true  => 'yes', false => 'no', }

  file { "${rsync::server::rsync_fragments}/frag-${name}":
    content => template('rsync/module.erb'),
    notify  => Exec['compile fragments'],
  }
}
