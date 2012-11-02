require 'backports'
require 'adamantium'
require 'equalizer'
require 'abstract_class'

# Namespace module 
module DataMapper
  class Session
    # Exception thrown on illegal state
    class StateError < RuntimeError; end
  end
end

require 'data_mapper/session'
require 'data_mapper/session/reader'
require 'data_mapper/session/mapping'
require 'data_mapper/session/tracker'
require 'data_mapper/session/identity'
require 'data_mapper/session/command'
require 'data_mapper/session/work'
require 'data_mapper/session/work/interceptor'
require 'data_mapper/session/registry'
require 'data_mapper/session/dump'
require 'data_mapper/session/state'
require 'data_mapper/session/state/new'
require 'data_mapper/session/state/dirty'
require 'data_mapper/session/state/loading'
require 'data_mapper/session/state/loaded'
