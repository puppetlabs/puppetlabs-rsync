# Definition: rsync::exec
define rsync::exec (
  $source,
  $path,
  $archive,
  $chown,
  $copylinks,
  $exclude,
  $execuser,
  $hardlinks,
  $include,
  $keyfile,
  $links,
  $onlyif,
  $options,
  $purge,
  $recursive,
  $timeout,
  $times,
  $user,
) {
  include rsync
  private('rsync::exec for use by rsync::get or rsync::put')

  validate_bool($archive,$copylinks,$hardlinks,$links,$purge,$recursive,$times)
  validate_re($timeout,'^[0-9]+$')
  if !is_string($exclude) { validate_array($exclude)      }
  if !is_string($include) { validate_array($include)      }
  if undef != $chown      { validate_string($chown)       }
  if undef != $keyfile    { validate_string($keyfile)     }
  if undef != $user       { validate_string($user)        }
  if undef != $port       { validate_re($port,'^[0-9]+$') }

  # Need to figure out if we're using SSH or not to decide about $user
  $remote_shell = $keyfile ? {
    undef   => undef,
    default => $user ? {
      undef   => "-e 'ssh -i ${keyfile}'",
      default => "-e 'ssh -i ${keyfile} -l ${user}'",
    },
  }
  $user_real = $user ? {
    undef   => undef,
    default => "${user}@",
  }

  # Validate our source/destination after deciding about $user.
  # Either source or path must be on our local filsystem.
  # Both may be local, or we may use ssh or rsync protocols for one.
  # We expect arguments like a form like:
  if $path  =~ /:/ {
    validate_absolute_path($source)
    validate_re($path,[
      '^/',            # local filesystem
      '^rsync://',     # rsync protocol
      '::',            # rsync protocol
      '(\b):[^:\b\B]', # ssh protocol
    ])
    $destination_real = $path ? {
      /^rsync:/ => regsubst($path,'^rsync:\/\/',"\0${user_real}"),
      default   => "${user_real}${path}",
    }
  } else {
    validate_absolute_path($path)
    $destination_real = $path
  }

  if $source  =~ /:/ {
    validate_absolute_path($path)
    validate_re($source,[
      '^/',            # local filesystem
      '^rsync://',     # rsync protocol
      '::',            # rsync protocol
      '(\b):[^:\b\B]', # ssh protocol
    ])
    $source_real = $source ? {
      /^rsync:/ => regsubst($source,'^rsync:\/\/',"\0${user_real}"),
      default   => "${user_real}${source}",
    }
  } else {
    validate_absolute_path($source)
    $source_real = $source
  }

  $execpath = $rsync::execpath

  # Don't need to set some supported options when archive is enabled.
  if $archive {
    $archive_real   = '--archive'
    $links_real     = undef
    $recursive_real = undef
    $times_real     = undef
  } else {
    $links_real     = $links     ? { true  => '--links',     false => undef }
    $recursive_real = $recursive ? { true  => '--recursive', false => undef }
    $times_real     = $times     ? { true  => '--times',     false => undef }
  }
  $copylinks_real = $copylinks ? { true  => '--copy-links', false => undef }
  $hardlinks_real = $hardlinks ? { true  => '--hard-links', false => undef }
  $purge_real     = $purge     ? { true  => '--delete',     false => undef }

  $chown_real   = $chown ? { undef => undef, default => "--chown=${chown}" }
  $exclude_real = $exclude ? {
    undef   => undef,
    default => join(prefix(flatten([$exclude]),'--exclude='),' '),
  }
  $include_real = $include ? {
    undef   => undef,
    default => join(prefix(flatten([$include]),'--include='),' '),
  }

  $rsync_options = join(flatten(delete_undef_values([
    $options,
    $archive_real,
    $purge_real,
    $exclude_real,
    $include_real,
    $links_real,
    $hardlinks_real,
    $copylinks_real,
    $times_real,
    $recursive_real,
    $chown_real,
    $remote_shell,
    $source_real,
    $destination_real,
  ])), ' ')

  $onlyif_real = $onlyif ? {
    undef   => "test `rsync -ni ${rsync_options} | wc -l` -gt 0",
    default => $onlyif,
  }

  # perform a dry-run to determine if anything needs to be updated
  # this ensures that we only actually create a Puppet event if
  # something needs to be updated
  # TODO - it may make senes to do an actual run here (instead of a
  #        dry run) and relace the command with an echo statement or
  #        something to ensure that we only actually run rsync once
  exec { "rsync ${name}":
    command => "rsync --quiet ${rsync_options}",
    path    => $execpath,
    user    => $execuser,
    onlyif  => $onlyif_real,
    timeout => $timeout,
  }
}
