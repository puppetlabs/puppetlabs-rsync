# puppetlabs-rsync #

puppetlabs-rsync manages rsync clients, repositories, and servers as well as
providing defines to easily grab data via rsync.

# Class: rsync #

Manage rsync package

## Parameters: ##
    $package_ensure - any of the valid values for the package resource: present, absent, purged, held, latest
    $manage_package - setting this to false stops the rsync package resource from being managed

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
    $times      - if set, rsync will use '--times'
    $include    - string (or array) to be included
    $exclude    - string (or array) to be excluded
    $keyfile    - ssh key used to connect to remote host
    $timeout    - timeout in seconds, defaults to 900
    $execuser   - user to run the command (passed to exec)
    $options    - default options to pass to rsync (-a)
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
    $include - string (or array) to be included
    $exclude - string (or array) to be excluded
    $keyfile - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
    $timeout - timeout in seconds, defaults to 900
    $options - default options to pass to rsync (-a)

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
    $path            - path to data
    $comment         - rsync comment
    $motd            - file containing motd info
    $read_only       - yes||no, defaults to yes
    $write_only      - yes||no, defaults to no
    $list            - yes||no, defaults to no
    $uid             - uid of rsync server, defaults to 0
    $gid             - gid of rsync server, defaults to 0
    $incoming_chmod  - incoming file mode, defaults to 644
    $outgoing_chmod  - outgoing file mode, defaults to 644
    $max_connections - maximum number of simultaneous connections allowed, defaults to 0
    $lock_file       - file used to support the max connections parameter, defaults to /var/run/rsyncd.lock only needed if max_connections > 0
    $secrets_file    - path to the file that contains the username:password pairs used for authenticating this module
    $auth_users      - list of usernames that will be allowed to connect to this module (must be undef or an array)
    $hosts_allow     - list of patterns allowed to connect to this module (man 5 rsyncd.conf for details, must be undef or an array)
    $hosts_deny      - list of patterns allowed to connect to this module (man 5 rsyncd.conf for details, must be undef or an array)
    $transfer_logging - parameter enables per-file logging of downloads and uploads in a format somewhat similar to that used by ftp daemons.
    $log_format       - This parameter allows you to specify the format used for logging file transfers when transfer logging is enabled. See the rsyncd.conf documentation for more details.
    $refuse_options  - list of rsync command line options that will be refused by your rsync daemon.

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

To disable default values for ``incoming_chmod`` and ``outgoing_chmod``, and
do not add empty values to the resulting config, set both values to ``false``

    rsync::server::module { 'repo':
      path           => $base,
      incoming_chmod => false,
      outgoing_chmod => false,
      require        => File[$base],
    }
