require 'backports'
require 'set'
require 'immutable'
require 'equalizer'
require 'abstract_class'

# Namespace module 
module DataMapper
  # Exception thrown on illegal state
  class StateError < RuntimeError; end
end

require 'data_mapper/session'
require 'data_mapper/mapping'
require 'data_mapper/tracker'
require 'data_mapper/identity'
require 'data_mapper/command'
require 'data_mapper/work'
require 'data_mapper/work/interceptor'
require 'data_mapper/registry'
require 'data_mapper/state'
require 'data_mapper/state/new'
require 'data_mapper/state/dirty'
require 'data_mapper/state/loading'
require 'data_mapper/state/loaded'
