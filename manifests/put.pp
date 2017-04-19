# Definition: rsync::put
#
# put files via rsync
#
# Parameters:
#   $source   - source to copy from
#   $path     - path to copy to, defaults to $name
#   $user     - username on remote system
#   $purge    - if set, rsync will use '--delete'
#   $exlude   - string to be excluded
#   $keyfile  - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
#   $timeout  - timeout in seconds, defaults to 900
#   $execuser - user to run the command (passed to exec)
#   $options  - default options to pass to rsync (-a)
#   $onlyif   - Condition to run the rsync command
#
# Actions:
#   put files via rsync
#
# Requires:
#   $source must be set
#
# Sample Usage:
#
#  rsync::put { '${rsyncDestHost}:/repo/foo':
#    user    => 'user',
#    source  => "/repo/foo/",
#  } # rsync
#
define rsync::put (
  $source,
  $path      = $name,
  $user      = undef,
  $purge     = undef,
  $exclude   = undef,
  $include   = undef,
  $keyfile   = undef,
  $timeout   = '900',
  $execuser  = undef,
  $options   = '-a',
  $onlyif    = undef,
) {

  if $keyfile {
    $myKeyfile = $keyfile
  } else {
    $myKeyfile = "/home/${user}/.ssh/id_rsa"
  }

  if $user {
    $myUserOpt = "-e 'ssh -i ${myKeyfile} -l ${user}'"
    $myUser = "${user}@"
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

  $rsync_options = join(
    delete_undef_values([$options, $myPurge, $myExclude, $myInclude, $myUserOpt, $source, "${myUser}${path}"]), ' ')

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
