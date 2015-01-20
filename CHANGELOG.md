##2015-01-20 - Release 0.4.0
###Summary

This release includes several new parameters and improvements.

####Features
- Update `$include` and `$exclude` to support arrays
- Updated to use puppetlabs/concat instead of execs to build file!
- New parameters
  - rsync::get
    - `$options`
    - `$onlyif`
  - rsync::put
    - `$include`
    - `$options`
  - rsync::server::module
    - `$order`
    - `$refuse_options`

####Bugfixes
- Fix auto-chmod of incoming and outgoing files when `incoming_chmod` or `outgoing_chmod` is set to false

##2014-07-15 - Release 0.3.1
###Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

##2014-06-18 - Release 0.3.0
####Features
- Added rsync::put defined type.
- Added 'recursive', 'links', 'hardlinks', 'copylinks', 'times' and 'include'
parameters to rsync::get.
- Added 'uid' and 'gid' parameters to rsync::server
- Improved support for Debian
- Added 'exclude' parameter to rsync::server::module

####Bugfixes
- Added /usr/local/bin to path for the rsync command exec.


##2013-01-31 - Release 0.2.0
- Added use_chroot parameter.
- Ensure rsync package is installed.
- Compatability changes for Ruby 2.0.
- Added execuser parameter to run command as specified user.
- Various typo and bug fixes.

##2012-06-07 - Release 0.1.0
- Initial release
