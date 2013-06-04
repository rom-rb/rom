require 'backports'
require 'backports/basic_object' unless defined?(::BasicObject)
require 'addressable/uri'
require 'axiom'
require 'abstract_type'
require 'descendants_tracker'
require 'equalizer'
require 'inflecto'

# Main ROM module with methods to setup and manage the environment
module ROM

  # Raised when the returned tuples are unexpectedly empty
  NoTuplesError = Class.new(RuntimeError)

  # Raised when the returned tuples are unexpectedly too many
  ManyTuplesError = Class.new(RuntimeError)

  # Represent an undefined argument
  Undefined = Object.new.freeze

  # An empty frozen Hash useful for parameter default values
  EMPTY_HASH = Hash.new.freeze

  # An empty frozen Array useful for parameter default values
  EMPTY_ARRAY = [].freeze

  # Represent a positive, infinitely large Float number
  Infinity  = 1.0 / 0

end # module ROM

require 'rom/utils'
require 'rom/support/options'

require 'rom/repository'
require 'rom/environment'

require 'rom/relation/header'
require 'rom/relation/header/attribute_index'
require 'rom/relation/header/relation_index'
require 'rom/relation/header/attribute'
require 'rom/relation/header/join_strategy'
require 'rom/relation/header/join_strategy/natural_join'
require 'rom/relation/header/join_strategy/inner_join'

require 'rom/relation/graph'
require 'rom/relation/graph/node'
require 'rom/relation/graph/edge'
