# Definition: rsync::get
#
# get files via rsync
#
# Parameters:
#   $source  - source to copy from
#   $path    - path to copy to, defaults to $name
#   $user    - username on remote system
#   $purge   - if set, rsync will use '--delete'
#   $exlude  - string to be excluded
#   $keyfile - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
#   $port    - ssh port
#   $timeout - timeout in seconds, defaults to 900
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
  $port       = undef,
  $timeout    = '900',
  $execuser   = 'root',
) {

  if $keyfile {
    $Mykeyfile = $keyfile
  } else {
    $Mykeyfile = "/home/${user}/.ssh/id_rsa"
  }

  if $user {
    $MyUser = "-e 'ssh -i ${Mykeyfile} -l ${user}' ${user}@"
  }

  if $purge {
    $MyPurge = ' --delete'
  }

  # Not currently correct, there can be multiple --exclude arguments
  if $exclude {
    $MyExclude = " --exclude=${exclude}"
  }

  # Not currently correct, there can be multiple --include arguments
  if $include {
    $MyInclude = " --include=${include}"
  }

  if $recursive {
    $MyRecursive = ' -r'
  }

  if $links {
    $MyLinks = ' --links'
  }

  if $hardlinks {
    $MyHardLinks = ' --hard-links'
  }

  if $copylinks {
    $MyCopyLinks = ' --copy-links'
  }

  if $times {
    $MyTimes = ' --times'
  }

  if $port {
    $MyPort = "-e \"ssh -p ${port}  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no\""
  }
  $rsync_options = "-a${MyPurge}${MyExclude}${MyInclude}${MyLinks}${MyHardLinks}${MyCopyLinks}${MyTimes}${MyRecursive}${MyPort} ${MyUser}${source} ${path}"

  exec { "rsync ${name}":
    command => "rsync -q ${rsync_options}",
    path    => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    user => $execuser,
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
