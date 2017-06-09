## Unsupported Release 1.0.0
### Summary
This is a major release that drops Puppet 3 support.

#### Added
- `transfer_logging` and `log_format` parameters
- Now optional management of rsync install with new `manage_package` parameter
- Support for configuration via Hiera
- FreeBSD, RedHat family compatibility
- Make rsync::get compatible with `strict_variables` ([MODULES-3515](https://tickets.puppet.com/browse/MODULES-3515))
- `ignore_nonreadable` parameter
- Support for changing exclude/include order
- `chmod` and `logfile` parameters
- `.sync.yml` added for modulesync compatibility

#### Changed
- Bumps puppetlabs-stdlib dependency up to 4.2.0

#### Fixed
- Replace .to_a with Kernel#Array ([MODULES-1858](https://tickets.puppet.com/browse/MODULES-1858))


## 2015-01-20 - Release 0.4.0
### Summary

This release includes several new parameters and improvements.

#### Features
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

#### Bugfixes
- Fix auto-chmod of incoming and outgoing files when `incoming_chmod` or `outgoing_chmod` is set to false

## 2014-07-15 - Release 0.3.1
### Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

## 2014-06-18 - Release 0.3.0
#### Features
- Added rsync::put defined type.
- Added `recursive`, `links`, `hardlinks`, `copylinks`, `times` and `include`
parameters to rsync::get.
- Added `uid` and `gid` parameters to rsync::server
- Improved support for Debian
- Added `exclude` parameter to rsync::server::module

#### Bugfixes
- Added /usr/local/bin to path for the rsync command exec.


## 2013-01-31 - Release 0.2.0
- Added use_chroot parameter.
- Ensure rsync package is installed.
- Compatability changes for Ruby 2.0.
- Added execuser parameter to run command as specified user.
- Various typo and bug fixes.

## 2012-06-07 - Release 0.1.0
- Initial release
