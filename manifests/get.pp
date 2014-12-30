# Definition: rsync::get
#
# get files via rsync
#
# Parameters:
#   $source  - source to copy from
#   $path    - path to copy to, defaults to $name
#   $user    - username on remote system
#   $purge   - if set, rsync will use '--delete'
#   $exclude - string (or array) to be excluded
#   $include - string (or array) to be included
#   $keyfile - path to ssh key used to connect to remote host,
#              defaults to /home/${user}/.ssh/id_rsa
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
  $timeout   = '900',
  $times     = false,
  $user      = undef,
) {
  validate_re($source,[
    '^/',            # local filesystem
    '(\b):[^:\b\B]', # ssh protocol
    '^rsync://',     # rsync protocol
    '::',            # rsync protocol
  ])
  validate_absolute_path($path)

  rsync::exec { "get ${name}":
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
