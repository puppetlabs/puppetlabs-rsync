# puppetlabs-rsync #

puppetlabs-rsync manages rsync clients, repositories, and servers as well as
providing defines to easily grab data via rsync.

# Class: rsync #

Manage rsync package

## Parameters: ##
    $package_ensure - any of the valid values for the package resource: present, absent, purged, held, latest

## Sample Usage: ##
    class { 'rsync': package_ensure => 'latest' }

# Definition: rsync::get #

get files via rsync

## Parameters: ##
    $source     - source to copy from
    $path       - path to copy to, defaults to $name
    $user       - username on remote system
    $purge      - if set, rsync will use '--delete'
    $recursive  - if set, rsync will use '-r'
    $links      - if set, rsync will use '--links'
    $hardlinks  - if set, rsync will use '--hard-links'
    $copylinks  - if set, rsync will use '--copy-links'
    $times      - if set, rsycn will use '--times'
    $include    - string to be included
    $exclude    - string to be excluded
    $keyfile    - ssh key used to connect to remote host
    $timeout    - timeout in seconds, defaults to 900
    $execuser   - user to run the command (passed to exec)
    $chown      - USER:GROUP simple username/groupname mapping
    $onlyif     - condition to run the rsync command

## Actions: ##
  get files via rsync

## Requires: ##
  $source must be set

## Sample Usage: ##
    # get file 'foo' via rsync
    rsync::get { '/foo':
      source  => "rsync://${rsyncServer}/repo/foo/",
      require => File['/foo'],
    }

# Definition: rsync::put #

put files via rsync

## Parameters: ##
    $source  - source to copy from
    $path    - path to copy to, defaults to $name
    $user    - username on remote system
    $purge   - if set, rsync will use '--delete'
    $exlude  - string to be excluded
    $keyfile - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
    $timeout - timeout in seconds, defaults to 900

## Actions: ##
  put files via rsync

## Requires: ##
  $source must be set

## Sample Usage: ##
    rsync::put { '${rsyncDestHost}:/repo/foo':
      user    => 'user',
      source  => "/repo/foo/",
    }

# Definition: rsync::server::module #

sets up a rsync server

## Parameters: ##
    $path           - path to data
    $comment        - rsync comment
    $motd           - file containing motd info
    $read_only      - yes||no, defaults to yes
    $write_only     - yes||no, defaults to no
    $list           - yes||no, defaults to no
    $uid            - uid of rsync server, defaults to 0
    $gid            - gid of rsync server, defaults to 0
    $incoming_chmod - incoming file mode, defaults to 644
    $outgoing_chmod - outgoing file mode, defaults to 644

## Actions: ##
  sets up an rsync server

## Requires: ##
  $path must be set

## Sample Usage: ##
    # setup default rsync repository
    rsync::server::module{ 'repo':
      path    => $base,
      require => File[$base],
    }
