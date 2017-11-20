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
#   $exclude_first - if 'true' (default) then first exclude and then include; the other way around if 'false'
#   $keyfile - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
#   $timeout - timeout in seconds, defaults to 900
#   $options - default options to pass to rsync (-a)
#   $chown   - ownership to pass to rsync (optional; requires rsync 3.1.0+)
#   $chmod   - permissions to pass to rsync (optional)
#   $logfile - logname to pass to rsync (optional)
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
  $path          = $name,
  $user          = undef,
  $purge         = undef,
  $recursive     = undef,
  $links         = undef,
  $hardlinks     = undef,
  $copylinks     = undef,
  $times         = undef,
  $include       = undef,
  $exclude       = undef,
  $exclude_first = true,
  $keyfile       = undef,
  $timeout       = '900',
  $execuser      = 'root',
  $options       = '-a',
  $chown         = undef,
  $chmod         = undef,
  $logfile       = undef,
  $onlyif        = undef,
) {

  if $keyfile {
    $mykeyfile = $keyfile
  } else {
    $mykeyfile = "/home/${user}/.ssh/id_rsa"
  }

  if $user {
    $myuser = "-e 'ssh -i ${mykeyfile} -l ${user}' ${user}@"
  } else {
    $myuser = undef
  }

  if $purge {
    $mypurge = '--delete'
  } else {
    $mypurge = undef
  }

  if $exclude {
    $myexclude = join(prefix(flatten([$exclude]), '--exclude='), ' ')
  } else {
    $myexclude = undef
  }

  if $include {
    $myinclude = join(prefix(flatten([$include]), '--include='), ' ')
  } else {
    $myinclude = undef
  }

  if $recursive {
    $myrecursive = '-r'
  } else {
    $myrecursive = undef
  }

  if $links {
    $mylinks = '--links'
  } else {
    $mylinks = undef
  }

  if $hardlinks {
    $myhardlinks = '--hard-links'
  } else {
    $myhardlinks = undef
  }

  if $copylinks {
    $mycopylinks = '--copy-links'
  } else {
    $mycopylinks = undef
  }

  if $times {
    $mytimes = '--times'
  } else {
    $mytimes = undef
  }

  if $chown {
    $mychown = "--chown=${chown}"
  } else {
    $mychown = undef
  }

  if $chmod {
    $mychmod = "--chmod=${chmod}"
  } else {
    $mychmod = undef
  }

  if $logfile {
    $mylogfile = "--log-file=${logfile}"
  } else {
    $mylogfile = undef
  }

  if $include or $exclude {
    if $exclude_first {
      $excludeandinclude = join(delete_undef_values([$myexclude, $myinclude]), ' ')
    } else {
      $excludeandinclude = join(delete_undef_values([$myinclude, $myexclude]), ' ')
    }
  } else {
    $excludeandinclude = undef
  }

  $rsync_options = join(
    delete_undef_values([$options, $mypurge, $excludeandinclude, $mylinks, $myhardlinks, $mycopylinks, $mytimes,
      $myrecursive, $mychown, $mychmod, $mylogfile, "${myuser}${source}", $path]), ' ')

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
