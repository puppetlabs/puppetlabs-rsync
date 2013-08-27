module Puppet::Parser::Functions
  VERBOSE_OR_QUIET_REGEX = /\-\w*[vq]|\-\-verbose|\-\-quiet/

  # returns true if the options passed doesn't contain verbose or quiet options, which mess with the rsync puppet module's
  # ability to detect whether or not to run rsync
  newfunction(:valid_options, :type => :rvalue) do |args|
    options = args[0]
    (options =~ VERBOSE_OR_QUIET_REGEX).nil?
  end
end
