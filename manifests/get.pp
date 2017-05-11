# Definition: rsync::get
#
# get files via rsync
#
# Parameters:
#   $source        - source to copy from
#   $path          - path to copy to, defaults to $name
#   $user          - username on remote system
#   $purge         - if set, rsync will use '--delete'
#   $exlude        - string (or array) to be excluded
#   $include       - string (or array) to be included
#   $exclude_first - if 'true' (default) then first exclude and then include; the other way around if 'false'
#   $keyfile       - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
#   $timeout       - timeout in seconds, defaults to 900
#   $options       - default options to pass to rsync (-a)
#   $onlyif        - Condition to run the rsync command
#
# Actions:
#   get files via rsync
#
# Requires:
#   $source must be set
#
# Sample Usage:
#
#  rsync::get { '/foo':
#    source  => "rsync://${rsyncServer}/repo/foo/",
#    require => File['/foo'],
#  } # rsync
#
define rsync::get (
  $source,
  $path          = $name,
  $user          = undef,
  $purge         = undef,
  $recursive     = undef,
  $links         = undef,
  $hardlinks     = undef,
  $copylinks     = undef,
  $times         = undef,
  $exclude       = undef,
  $include       = undef,
  $exclude_first = true,
  $keyfile       = undef,
  $timeout       = '900',
  $execuser      = 'root',
  $options       = '-a',
  $chown         = undef,
  $onlyif        = undef,
) {

  if $keyfile {
    $mykeyfile = $keyfile
  } else {
    $mykeyfile = "/home/${user}/.ssh/id_rsa"
  }

  if $user {
    $myUser = "-e 'ssh -i ${mykeyfile} -l ${user}' ${user}@"
  } else {
    $myUser = undef
  }

  if $purge {
    $myPurge = '--delete'
  } else {
    $myPurge = undef
  }

  if $exclude {
    $myExclude = join(prefix(flatten([$exclude]), '--exclude='), ' ')
  } else {
    $myExclude = undef
  }

  if $include {
    $myInclude = join(prefix(flatten([$include]), '--include='), ' ')
  } else {
    $myInclude = undef
  }

  if $recursive {
    $myRecursive = '-r'
  } else {
    $myRecursive = undef
  }

  if $links {
    $myLinks = '--links'
  } else {
    $myLinks = undef
  }

  if $hardlinks {
    $myHardLinks = '--hard-links'
  } else {
    $myHardLinks = undef
  }

  if $copylinks {
    $myCopyLinks = '--copy-links'
  } else {
    $myCopyLinks = undef
  }

  if $times {
    $myTimes = '--times'
  } else {
    $myTimes = undef
  }

  if $chown {
    $myChown = "--chown=${chown}"
  } else {
    $myChown = undef
  }

  if $include or $exclude {
    if $exclude_first {
      $excludeAndInclude = join(delete_undef_values([$myExclude, $myInclude]), ' ')
    } else {
      $excludeAndInclude = join(delete_undef_values([$myInclude, $myExclude]), ' ')
    }
  }

  $rsync_options = join(
    delete_undef_values([$options, $myPurge, $excludeAndInclude, $myLinks, $myHardLinks, $myCopyLinks, $myTimes,
      $myRecursive, $myChown, "${myUser}${source}", $path]), ' ')

  if !$onlyif {
    $onlyif_real = "test `rsync --dry-run --itemize-changes ${rsync_options} | wc -l` -gt 0"
  } else {
    $onlyif_real = $onlyif
  }


  exec { "rsync ${name}":
    command => "rsync -q ${rsync_options}",
    path    => [ '/bin', '/usr/bin', '/usr/local/bin' ],
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
