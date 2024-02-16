# @summary
#   put files via rsync
#
# @param source
#   source to copy from
# @param path
#   path to copy to, defaults to $name
# @param user
#   username on remote system
# @param purge
#   if set, rsync will use '--delete'
# @param exlude
#   Path or paths to be exclude
# @param include
#   Path or paths to be included
# @param exclude_first
#   if 'true' (default) then first exclude and then include; the other way around if 'false'
# @param keyfile
#   path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
# @param timeout
#   timeout in seconds, defaults to 900
# @param options
#   default options to pass to rsync (-a)
#
# @example Sync to remote
#  rsync::put { '${rsyncDestHost}:/repo/foo':
#    user    => 'user',
#    source  => "/repo/foo/",
#  } # rsync
#
define rsync::put (
  String[1] $source,
  String[1] $path = $name,
  Optional[String[1]] $user = undef,
  Boolean $purge = false,
  Variant[Array[String[1]], String[1]] $exclude = [],
  Variant[Array[String[1]], String[1]] $include = [],
  Boolean $exclude_first = true,
  Optional[String[1]] $keyfile = undef,
  Integer[0] $timeout = 900,
  Array[String[1]] $options = ['-a'],
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

  $myexclude = prefix(flatten([$exclude]), '--exclude=')
  $myinclude = prefix(flatten([$include]), '--include=')

  if $exclude_first {
    $excludeandinclude = $myexclude + $myinclude
  } else {
    $excludeandinclude = $myinclude + $myexclude
  }

  $rsync_options = $options + $mypurge + $excludeandinclude + $myuseropt + [$source, "${myuser}${path}"]
  $command = ['rsync' + '-q'] + $rsync_options
  $rsync_options_str = join($rsync_options, ' ')

  exec { "rsync ${name}":
    command => $command,
    path    => ['/bin', '/usr/bin'],
    # perform a dry-run to determine if anything needs to be updated
    # this ensures that we only actually create a Puppet event if something needs to
    # be updated
    # TODO - it may make senes to do an actual run here (instead of a dry run)
    #        and relace the command with an echo statement or something to ensure
    #        that we only actually run rsync once
    onlyif  => "test `rsync --dry-run --itemize-changes ${rsync_options_str} | wc -l` -gt 0",
    timeout => $timeout,
  }
}
