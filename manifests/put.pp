# Definition: rsync::put
#
# put files via rsync
#
# Parameters:
#   $source        - source to copy from
#   $path          - path to copy to, defaults to $name
#   $user          - username on remote system
#   $purge         - if set, rsync will use '--delete'
#   $exlude        - string (or array) to be excluded
#   $include       - string (or array) to be included
#   $exclude_first - if 'true' then first exclude and then include; the other way around if 'false'
#   $keyfile       - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
#   $timeout       - timeout in seconds, defaults to 900
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
  $path          = undef,
  $user          = undef,
  $purge         = undef,
  $exclude       = undef,
  $include       = undef,
  $exclude_first = true,
  $keyfile       = undef,
  $timeout       = '900',
  $options       = '-a'
) {

  if $keyfile {
    $mykeyfile = $keyfile
  } else {
    $mykeyfile = "/home/${user}/.ssh/id_rsa"
  }

  if $user {
    $myuseropt = "-e 'ssh -i ${mykeyfile} -l ${user}'"
    $myuser = "${user}@"
  } else {
    $myuseropt = undef
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

  if $include or $exclude {
    if $exclude_first {
      $excludeandinclude = join(delete_undef_values([$myexclude, $myinclude]), ' ')
    } else {
      $excludeandinclude = join(delete_undef_values([$myinclude, $myexclude]), ' ')
    }
  } else {
    $excludeandinclude = undef
  }

  if $path {
    $mypath = $path
  } else {
    $mypath = $name
  }

  $rsync_options = join(
    delete_undef_values([$options, $mypurge, $excludeandinclude, $myuseropt, $source, "${myuser}${mypath}"]), ' ')

  exec { "rsync ${name}":
    command => "rsync -q ${rsync_options}",
    path    => [ '/bin', '/usr/bin' ],
    # perform a dry-run to determine if anything needs to be updated
    # this ensures that we only actually create a Puppet event if something needs to
    # be updated
    # TODO - it may make senes to do an actual run here (instead of a dry run)
    #        and relace the command with an echo statement or something to ensure
    #        that we only actually run rsync once
    onlyif  => "test `rsync --dry-run --itemize-changes ${rsync_options} | wc -l` -gt 0",
    timeout => $timeout,
  }
}
