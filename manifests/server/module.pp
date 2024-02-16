# @summary
#   sets up a rsync server
#
# @param path
#   path to data
# @param order
#   order of concat resource
# @param comment
#   rsync comment
# @param use_chroot
#   use chroot during file transfer
# @param read_only
#   whether clients will be able to upload files or not
# @param write_only
#   whether clients will be able to download files or not
# @param list
#   if the module should be listed when the client asks for a listing of available modules.
# @param uid
#   uid of rsync server
# @param gid
#   gid of rsync server
# @param numeric_ids
#   Don't resolve uids to usernames
# @param ignore_nonreadable
#   do not display files the daemon cannot read.
# @param incoming_chmod
#   incoming file mode
# @param outgoing_chmod
#   outgoing file mode
# @param max_connections
#   maximum number of simultaneous connections allowed
# @param lock_file
#   file used to support the max connections parameter
#   only needed if max_connections > 0
# @param secrets_file
#   path to the file that contains the username:password pairs used for authenticating this module
# @param auth_users
#   list of usernames that will be allowed to connect to this module (must be undef or an array)
# @param hosts_allow
#   list of patterns allowed to connect to this module (man 5 rsyncd.conf for details, must be undef or an array)
# @param hosts_deny
#   list of patterns allowed to connect to this module (man 5 rsyncd.conf for details, must be undef or an array)
# @param timeout
#   disconnect client after X seconds of inactivity
# @param transfer_logging
#   parameter enables per-file logging of downloads and
#   uploads in a format somewhat similar to that used by ftp daemons.
# @param log_format
#   This parameter allows you to specify the format used
#   for logging file transfers when transfer logging is enabled. See the
#   rsyncd.conf documentation for more details.
# @param log_file
#   log messages to the indicated file rather than using syslog
# @param refuse_options
#   list of rsync command line options that will be refused by your rsync daemon.
# @param include
#   list of files to include
# @param include_from
#   file containing a list of files to include
# @param exclude
#   list of files to exclude
# @param exclude_from
#   file containing a list of files to exclude
# @param dont_compress
#   disable compression on matching files
#
# @example setup default rsync repository
#   rsync::server::module { 'repo':
#     path    => $base,
#     require => File[$base],
#   }
#
define rsync::server::module (
  String[1] $path,
  String[1] $order = "10_${name}",
  Optional[String[1]] $comment = undef,
  Optional[Boolean] $use_chroot = undef,
  Boolean $read_only = true,
  Boolean $write_only = false,
  Boolean $list = true,
  Optional[String[1]] $uid = undef,
  Optional[String[1]] $gid = undef,
  Optional[Boolean] $numeric_ids = undef,
  Optional[String[1]] $incoming_chmod = undef,
  Optional[String[1]] $outgoing_chmod = undef,
  Integer[0] $max_connections = 0,
  Integer[0] $timeout = 0,
  Stdlib::Absolutepath $lock_file = '/var/run/rsyncd.lock',
  Optional[Stdlib::Absolutepath] $secrets_file = undef,
  Optional[Array[String[1]]] $auth_users = undef,
  Optional[Array[String[1]]] $hosts_allow = undef,
  Optional[Array[String[1]]] $hosts_deny = undef,
  Optional[Boolean] $transfer_logging = undef,
  Optional[Stdlib::Absolutepath] $log_file = undef,
  Optional[String[1]] $log_format = undef,
  Optional[Array[String[1]]] $refuse_options = undef,
  Optional[Array[String[1]]] $include = undef,
  Optional[String[1]] $include_from = undef,
  Optional[Array[String[1]]] $exclude = undef,
  Optional[String[1]] $exclude_from = undef,
  Optional[Array[String[1]]] $dont_compress = undef,
  Optional[Boolean] $ignore_nonreadable = undef
)  {
  concat::fragment { "frag-${name}":
    content => template('rsync/module.erb'),
    target  => $rsync::server::conf_file,
    order   => $order,
  }
}
