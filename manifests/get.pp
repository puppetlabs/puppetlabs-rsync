# @summary
#   get files via rsync
#
# @param source
#   source to copy from
# @param path
#   path to copy to, defaults to $name
# @param user
#   username on remote system
# @param purge
#   if set, rsync will use '--delete'
# @param exclude
#   Path or paths to be exclude
# @param include
#   Path or paths to include
# @param exclude_first
#   if 'true' (default) then first exclude and then include; the other way around if 'false'
# @param keyfile
#   path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
# @param timeout
#   timeout in seconds, defaults to 900
# @param options
#   default options to pass to rsync (-a)
# @param chown
#   ownership to pass to rsync (requires rsync 3.1.0+)
# @param chmod
#   permissions to pass to rsync
# @param logfile
#   logname to pass to rsync
# @param onlyif
#   Condition to run the rsync command
#
# @example Sync from a source
#  rsync::get { '/foo':
#    source  => "rsync://${rsyncServer}/repo/foo/",
#    require => File['/foo'],
#  }
#
define rsync::get (
  String[1] $source,
  String[1] $path = $name,
  Optional[String[1]] $user = undef,
  Boolean $purge = false,
  Boolean $recursive = false,
  Boolean $links = false,
  Boolean $hardlinks = false,
  Boolean $copylinks = false,
  Boolean $times = false,
  Variant[Array[String[1]], String[1]] $include = [],
  Variant[Array[String[1]], String[1]] $exclude = [],
  Boolean $exclude_first = true,
  Optional[String[1]] $keyfile = undef,
  Integer[0] $timeout = 900,
  String[1] $execuser = 'root',
  Array[String[1]] $options = ['-a'],
  Optional[String[1]] $chown = undef,
  Optional[String[1]] $chmod = undef,
  Optional[String[1]] $logfile       = undef,
  Variant[Undef, String[1], Array[String[1]]] $onlyif = undef,
) {
  if $keyfile {
    $mykeyfile = $keyfile
  } else {
    $mykeyfile = "/home/${user}/.ssh/id_rsa"
  }

  if $user {
    $myuseropt = ['-e', "'ssh -i ${mykeyfile} -l ${user}'"]
    $myuser = "${user}@"
  } else {
    $myuseropt = []
    $myuser = ''
  }

  if $purge {
    $mypurge = ['--delete']
  } else {
    $mypurge = []
  }

  $myexclude = prefix(any2array($exclude), '--exclude=')
  $myinclude = prefix(any2array($include), '--include=')

  if $recursive {
    $myrecursive = ['-r']
  } else {
    $myrecursive = []
  }

  if $links {
    $mylinks = ['--links']
  } else {
    $mylinks = []
  }

  if $hardlinks {
    $myhardlinks = ['--hard-links']
  } else {
    $myhardlinks = []
  }

  if $copylinks {
    $mycopylinks = ['--copy-links']
  } else {
    $mycopylinks = []
  }

  if $times {
    $mytimes = ['--times']
  } else {
    $mytimes = []
  }

  if $chown {
    $mychown = ["--chown=${chown}"]
  } else {
    $mychown = []
  }

  if $chmod {
    $mychmod = ["--chmod=${chmod}"]
  } else {
    $mychmod = []
  }

  if $logfile {
    $mylogfile = ["--log-file=${logfile}"]
  } else {
    $mylogfile = []
  }

  if $exclude_first {
    $excludeandinclude = $myexclude + $myinclude
  } else {
    $excludeandinclude = $myinclude + $myexclude
  }

  $rsync_options = $options + $mypurge + $excludeandinclude + $mylinks + $myhardlinks + $mycopylinks + $mytimes + $myrecursive + $mychown + $mychmod + $mylogfile + $myuseropt + ["${myuser}${source}", $path]
  $command = ['rsync' + '-q'] + $rsync_options
  $rsync_options_str = join($rsync_options, ' ')

  if $onlyif {
    $onlyif_real = $onlyif
  } else {
    # TODO: add dry run to $command?
    $onlyif_real = "test `rsync --dry-run --itemize-changes ${rsync_options_str} | wc -l` -gt 0"
  }

  exec { "rsync ${name}":
    command => $command,
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    user    => $execuser,
    # perform a dry-run to determine if anything needs to be updated
    # this ensures that we only actually create a Puppet event if something needs to
    # be updated
    # TODO - it may make senes to do an actual run here (instead of a dry run)
    #        and relace the command with an echo statement or something to ensure
    #        that we only actually run rsync once
    onlyif  => $onlyif_real,
    timeout => $timeout,
  }
}
