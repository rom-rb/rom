if RUBY_VERSION < '1.9'
  require 'backports'
end

require 'set'

# Namespace module for session library
module Session
  class StateError < RuntimeError; end
end

require 'session/session'
require 'session/object_state'
