require 'backports'
require 'adamantium'
require 'equalizer'
require 'abstract_type'

# Namespace module 
module DataMapper
  class Session
    # Exception thrown on illegal state
    class StateError < RuntimeError; end
  end
end

require 'data_mapper/session'
require 'data_mapper/session/reader'
require 'data_mapper/session/state'
require 'data_mapper/session/operand'
require 'data_mapper/session/work'
require 'data_mapper/session/work/interceptor'
require 'data_mapper/session/registry'
