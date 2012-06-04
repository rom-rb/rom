if RUBY_VERSION < '1.9'
  require 'backports'
end

require 'set'

# Namespace module for session library
module Session
  # Exception thrown on illegal domain object states
  class StateError < RuntimeError; end
end

require 'session/session'
require 'session/object_state'
require 'session/object_state/new'
require 'session/object_state/forgotten'
require 'session/object_state/loaded'
