# puppetlabs-rsync #

#### Table of Contents

1. [Module Description - What does the module do?](#module-description)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Defined Types](#defined-types)
5. [Limitations - OS compatibility, etc.](#limitations)

## Module description

puppetlabs-rsync manages rsync clients, repositories, and servers as well as
providing defines to easily grab data via rsync.

## Usage

Install the latest version of rsync
~~~puppet
class { 'rsync': 
  package_ensure => 'latest' 
}
~~~

Get file 'foo' via rsync
~~~puppet
rsync::get { '/foo':
  source  => "rsync://${rsyncServer}/repo/foo/",
  require => File['/foo'],
}
~~~

Put file 'foo' on 'rsyncDestHost'
~~~puppet
rsync::put { '${rsyncDestHost}:/repo/foo':
  user    => 'user',
  source  => "/repo/foo/",
}
~~~

Setup default rsync repository
~~~puppet
rsync::server::module{ 'repo':
  path    => $base,
  require => File[$base],
}
~~~

To disable default values for `incoming_chmod` and `outgoing_chmod`, and
do not add empty values to the resulting config, set both values to `false`

~~~puppet
rsync::server::module { 'repo':
  path           => $base,
  incoming_chmod => false,
  outgoing_chmod => false,
  require        => File[$base],
}
~~~

#### Configuring via Hiera 
`rsync::put`, `rsync::get`, and `rsync::server::module` resources can be
configured using Hiera hashes. For example:

~~~yaml
rsync::server::modules:
  myrepo:
    path: /mypath
    incoming_chmod: false
    outgoing_chmod: false
  myotherrepo:
    path: /otherpath
    read_only: false
~~~

## Reference

**Classes:**
* [rsync](#rsync)

**Defined Types:**
* [rsync::get](#rsyncget)
* [rsync::put](#rsyncput)
* [rsync::server::module](#rsyncservermodule)


### Classes

#### rsync

Manage the rsync package.

##### `package_ensure`

Ensure the for the rsync package. Any of the valid values for the package resource (present, absent, purged, held, latest) are acceptable.

Default value: 'installed' 

##### `manage_package`

Setting this to false stops the rsync package resource from being managed.

Default value: `true`

### Defined Types

#### rsync::get

get files via rsync

##### `source`
**Required**

Source to copy from.

##### `path`

Path to copy to.

Default value: `$name`

##### `user` 

Username on remote system

##### `purge`

If set, rsync will use '--delete'

##### `recursive`

If set, rsync will use '-r'

##### `links`

If set, rsync will use '--links'

##### `hardlinks`

If set, rsync will use '--hard-links'

##### `copylinks`

If set, rsync will use '--copy-links'

##### `times`

If set, rsync will use '--times'

##### `exclude`

String (or array of strings) paths for files to be excluded.

##### `include`

String (or array of strings) paths for files to be explicitly included.

##### `exclude_first`

If `true`, exclude first and then include; the other way around if `false`.

Default value: `true`

##### `keyfile`

SSH key used to connect to remote host.

##### `timeout`

Timeout in seconds.

Default value: 900

##### `execuser`

User to run the command (passed to exec).

##### `options`

Default options to pass to rsync (-a).

##### `chown`

USER:GROUP simple username/groupname mapping.

##### `chmod`

File and/or directory permissions.

##### `logfile`

Log file name.

##### `onlyif`

Condition to run the rsync command.

#### rsync::put

put files via rsync

##### `source`
**Required**

Source to copy from.

##### `path`

Path to copy to.

Default value: `$name`

##### `user`

Username on target remote system.

##### `purge`

If set, rsync will use '--delete'

##### `exclude`

String (or array of strings) paths for files to be excluded.

##### `include`

String (or array of strings) paths for files to be explicitly included.

##### `exclude_first`

If `true`, exclude first and then include; the other way around if `false`.

Default value: `true`

##### `keyfile`

Path to SSH key used to connect to remote host.

Default value: '/home/${user}/.ssh/id_rsa'

##### `timeout`

Timeout in seconds.

Default value: 900

##### `options`

Default options to pass to rsync (-a)

#### rsync::server::module

Sets up a rsync server

##### `path`
_Required_

Path to data.

##### `comment`

Rsync comment.

##### `motd`

File containing motd info.

##### `read_only`

yes||no 

Default value: 'yes'

##### `write_only`

yes||no

Default value: 'no'

##### `list`

yes||no

Default value: 'no'

##### `uid`

uid of rsync server 

Default value: 0

##### `gid`

gid of rsync server

Default value: 0

##### `incoming_chmod`

Incoming file mode 

Default value: '644'

##### `outgoing_chmod`

Outgoing file mode

Default value: '644'

##### `max_connections`

Maximum number of simultaneous connections allowed

Default value: 0

##### `lock_file`

File used to support the max connections parameter. Only needed if max_connections > 0.

Default value: '/var/run/rsyncd.lock' 

##### `secrets_file`

Path to the file that contains the username:password pairs used for authenticating this module.

##### `auth_users`

List of usernames that will be allowed to connect to this module (must be undef or an array).

##### `hosts_allow`

List of patterns allowed to connect to this module ([rsyncd.conf man page] for details, must be undef or an array).

##### `hosts_deny`

List of patterns allowed to connect to this module ([rsyncd.conf man page] for details, must be undef or an array).

##### `transfer_logging`

Parameter enables per-file logging of downloads and uploads in a format somewhat similar to that used by ftp daemons.

##### `log_format`

This parameter allows you to specify the format used for logging file transfers when transfer logging is enabled. See the [rsyncd.conf man page] for more details.

##### `refuse_options`

List of rsync command line options that will be refused by your rsync daemon.

##### `ignore_nonreadable`

This  tells  the  rsync daemon to completely ignore files that are not readable by the user.

[rsyncd.conf man page]:https://download.samba.org/pub/rsync/rsyncd.conf.html
