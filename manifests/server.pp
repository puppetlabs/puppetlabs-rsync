# Class: rsync::server
#
# The rsync server. Supports both standard rsync as well as rsync over ssh
#
# Requires:
#   class xinetd if use_xinetd is set to true
#   class rsync
#
class rsync::server(
  $use_xinetd = true,
  $address = '0.0.0.0'
) inherits rsync {


    $rsync_fragments = "/etc/rsync.d"

    # Definition: rsync::server::module
    #
    # sets up a rsync server
    #
    # Parameters:
    #   $path            - path to data
    #   $comment         - rsync comment
    #   $motd            - file containing motd info
    #   $read_only       - yes||no, defaults to yes
    #   $write_only      - yes||no, defaults to no
    #   $list            - yes||no, defaults to no
    #   $uid             - uid of rsync server, defaults to 0
    #   $gid             - gid of rsync server, defaults to 0
    #   $incoming_chmod  - incoming file mode, defaults to 644
    #   $outgoing_chmod  - outgoing file mode, defaults to 644
    #   $max_connections - maximum number of simultaneous connections allowed
    #   $lock_file       - file used to support the max connections parameter
    #    only needed if max_connections > 0
    #
    # Actions:
    #   sets up an rsync server
    #
    # Requires:
    #   $path must be set
    #
    # Sample Usage:
    #   # setup default rsync repository
    #   rsync::server::module{ "repo":
    #       path    => $base,
    #       require => File["$base"],
    #   } # rsync::server::module
    #
    define module ($path, $comment = undef, $motd = undef, $read_only = 'yes', $write_only = 'no', $list = 'yes', $uid = '0', $gid = '0', $incoming_chmod = '644', $outgoing_chmod = '644', $max_connections = 0, $lock_file = '/var/run/rsyncd.lock')  {
        if $motd {
            file { "/etc/rsync-motd-$name":
                source => "puppet:///modules/rsync/motd-$motd",
            }
        } # fi

        file { "$rsync::server::rsync_fragments/frag-$name":
           content => template("rsync/module.erb"),
           notify  => Exec["compile fragments"],
        }
    } # define rsync::server::module

    if($use_xinetd) {
      include xinetd
      xinetd::service {"rsync":
          port        => "873",
          server      => "/usr/bin/rsync",
          server_args => "--daemon --config /etc/rsync.conf",
      } # xinetd::service
    } else {
      service { 'rsync':
        ensure    => running,
        enable    => true,
        subscribe => Exec['compile fragments'],
      }
    }

    file {
        "$rsync_fragments":
            ensure  => directory;
        "$rsync_fragments/header":
            content => template('rsync/header.erb');
    } # file

    # perhaps this should be a script
    # this allows you to only have a header and no fragments, which happens
    # by default if you have an rsync::server but not an rsync::repo on a host
    # which happens with cobbler systems by default
    exec {"compile fragments":
        refreshonly => true,
        command     => "ls $rsync_fragments/frag-* 1>/dev/null 2>/dev/null && if [ $? -eq 0 ]; then cat $rsync_fragments/header $rsync_fragments/frag-* > /etc/rsync.conf; else cat $rsync_fragments/header > /etc/rsync.conf; fi; $(exit 0)",
        subscribe   => File["$rsync_fragments/header"],
        path        => ['/bin'],
    } # exec
} # class rsync::server
