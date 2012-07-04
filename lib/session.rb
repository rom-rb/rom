require 'backports'
require 'set'
require 'veritas'

# Namespace module for session library
module Session
  # An undefined argument
  Undefined = Object.new.freeze
  # Exception thrown on illegal domain object states
  class StateError < RuntimeError; end
end

require 'session/session'
require 'session/object_state'
require 'session/object_state/new'
require 'session/object_state/forgotten'
require 'session/object_state/loaded'
