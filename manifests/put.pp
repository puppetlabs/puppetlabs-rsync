# Definition: rsync::put
#
# put files via rsync
#
# Parameters:
#   $source  - source to copy from
#   $path    - path to copy to, defaults to $name
#   $user    - username on remote system
#   $purge   - if set, rsync will use '--delete'
#   $exlude  - string (or array) to be excluded
#   $include - string (or array) to be included
#   $keyfile - path to ssh key used to connect to remote host,
#              defaults to /home/${user}/.ssh/id_rsa
#   $timeout - timeout in seconds, defaults to 900
#   $options - default options to pass to rsync (-a)
#
# Actions:
#   put files via rsync
#
# Requires:
#   $source must be set
#
# Sample Usage:
#
#  rsync::put { "${rsyncDestHost}:/repo/foo":
#    user    => 'user',
#    source  => "/repo/foo/",
#  }
#
define rsync::put (
  $source,
  $archive   = true,
  $chown     = undef,
  $copylinks = false,
  $exclude   = undef,
  $execpath  = undef,
  $execuser  = 'root',
  $hardlinks = false,
  $include   = undef,
  $keyfile   = undef,
  $links     = false,
  $options   = undef,
  $path      = $name,
  $purge     = false,
  $onlyif    = undef,
  $recursive = false,
  $rsh       = undef,
  $timeout   = '900',
  $times     = false,
  $user      = undef,
) {
  validate_re($path,[
    '^/',            # local filesystem
    '(\b):[^:\b\B]', # ssh protocol
    '^rsync://',     # rsync protocol
    '::',            # rsync protocol
  ])
  validate_absolute_path($source)

  rsync::exec { "put ${name}":
    archive   => $archive,
    chown     => $chown,
    copylinks => $copylinks,
    exclude   => $exclude,
    execuser  => $execuser,
    hardlinks => $hardlinks,
    include   => $include,
    keyfile   => $keyfile,
    links     => $links,
    onlyif    => $onlyif,
    options   => $options,
    path      => $path,
    purge     => $purge,
    recursive => $recursive,
    source    => $source,
    timeout   => $timeout,
    times     => $times,
    user      => $user,
  }
}
