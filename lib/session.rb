require 'backports'
require 'set'
require 'immutable'
require 'equalizer'
require 'abstract_class'

# Namespace module 
module Session
  # An undefined argument
  Undefined = Object.new.freeze

  # Exception thrown on illegal domain object state
  class StateError < RuntimeError; end
end

require 'session/session'
require 'session/mapping'
require 'session/tracker'
require 'session/registry'
require 'session/state'
require 'session/state/new'
require 'session/state/forgotten'
require 'session/state/loaded'
