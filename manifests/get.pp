# Definition: rsync::get
#
# get files via rsync
#
# Parameters:
#   $source  - source to copy from
#   $path    - path to copy to, defaults to $name
#   $user    - username on remote system
#   $purge   - if set, rsync will use '--delete'
#   $exlude  - string (or array) to be excluded
#   $include - string (or array) to be included
#   $keyfile - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
#   $timeout - timeout in seconds, defaults to 900
#   $options - default options to pass to rsync (-a)
#   $onlyif  - Condition to run the rsync command
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
  $path       = $name,
  $user       = undef,
  $purge      = undef,
  $recursive  = undef,
  $links      = undef,
  $hardlinks  = undef,
  $copylinks  = undef,
  $times      = undef,
  $include    = undef,
  $exclude    = undef,
  $keyfile    = undef,
  $timeout    = '900',
  $execuser   = 'root',
  $options    = '-a',
  $chown      = undef,
  $onlyif     = undef,
) {

  if $keyfile {
    $mykeyfile = $keyfile
  } else {
    $mykeyfile = "/home/${user}/.ssh/id_rsa"
  }

  if $user {
    $myUser = "-e 'ssh -i ${mykeyfile} -l ${user}' ${user}@"
  }

  if $purge {
    $myPurge = '--delete'
  }

  if $exclude {
    $myExclude = join(prefix(flatten([$exclude]), '--exclude='), ' ')
  }

  if $include {
    $myInclude = join(prefix(flatten([$include]), '--include='), ' ')
  }

  if $recursive {
    $myRecursive = '-r'
  }

  if $links {
    $myLinks = '--links'
  }

  if $hardlinks {
    $myHardLinks = '--hard-links'
  }

  if $copylinks {
    $myCopyLinks = '--copy-links'
  }

  if $times {
    $myTimes = '--times'
  }

  if $chown {
    $myChown = "--chown=${chown}"
  }

  $rsync_options = join(
    delete_undef_values([$options, $myPurge, $myExclude, $myInclude, $myLinks, $myHardLinks, $myCopyLinks, $myTimes, $myRecursive, $myChown, "${myUser}${source}", $path]), ' ')

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
