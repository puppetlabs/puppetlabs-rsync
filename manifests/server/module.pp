# Definition: rsync::server::module
#
# sets up a rsync server
#
# Parameters:
#   $path               - path to data
#   $comment            - rsync comment
#   $use_chroot         - yes||no, defaults to undef
#   $read_only          - yes||no, defaults to yes
#   $write_only         - yes||no, defaults to no
#   $list               - yes||no, defaults to yes
#   $uid                - uid of rsync server
#   $gid                - gid of rsync server
#   $numeric_ids        - yes||no, don't resolve uids to usernames, defaults to undef
#   $ignore_nonreadable - do not display files the daemon cannot read, defaults to yes
#   $incoming_chmod     - incoming file mode
#   $outgoing_chmod     - outgoing file mode
#   $max_connections    - maximum number of simultaneous connections allowed, defaults to 0
#   $lock_file          - file used to support the max connections parameter, defaults to /var/run/rsyncd.lock
#    only needed if max_connections > 0
#   $secrets_file       - path to the file that contains the username:password pairs used for authenticating this module
#   $auth_users         - list of usernames that will be allowed to connect to this module (must be undef or an array)
#   $hosts_allow        - list of patterns allowed to connect to this module (man 5 rsyncd.conf for details, must be undef or an array)
#   $hosts_deny         - list of patterns allowed to connect to this module (man 5 rsyncd.conf for details, must be undef or an array)
#   $timeout            - disconnect client after X seconds of inactivity, defaults to 0
#   $transfer_logging   - parameter enables per-file logging of downloads and
#    uploads in a format somewhat similar to that used by ftp daemons.
#   $log_format         - This parameter allows you to specify the format used
#    for logging file transfers when transfer logging is enabled. See the
#    rsyncd.conf documentation for more details.
#   $log_file         - log messages to the indicated file rather than using syslog
#   $refuse_options     - list of rsync command line options that will be refused by your rsync daemon.
#   $include            - list of files to include
#   $include_from       - file containing a list of files to include
#   $exclude            - list of files to exclude
#   $exclude_from       - file containing a list of files to exclude
#   $dont_compress      - disable compression on matching files
#
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
  $order              = "10_${name}",
  $comment            = undef,
  $use_chroot         = undef,
  $read_only          = 'yes',
  $write_only         = 'no',
  $list               = 'yes',
  $uid                = undef,
  $gid                = undef,
  $numeric_ids        = undef,
  $incoming_chmod     = undef,
  $outgoing_chmod     = undef,
  $max_connections    = '0',
  $timeout            = '0',
  $lock_file          = '/var/run/rsyncd.lock',
  $secrets_file       = undef,
  $auth_users         = undef,
  $hosts_allow        = undef,
  $hosts_deny         = undef,
  $transfer_logging   = undef,
  $log_file           = undef,
  $log_format         = undef,
  $refuse_options     = undef,
  $include            = undef,
  $include_from       = undef,
  $exclude            = undef,
  $exclude_from       = undef,
  $dont_compress      = undef,
  $ignore_nonreadable = undef)  {

  concat::fragment { "frag-${name}":
    content => template('rsync/module.erb'),
    target  => $rsync::server::conf_file,
    order   => $order,
  }
}
