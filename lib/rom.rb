require 'bigdecimal'
require 'date'

require 'backports'
require 'backports/basic_object' unless defined?(::BasicObject)
require 'addressable/uri'
require 'axiom'
require 'abstract_type'
require 'descendants_tracker'
require 'equalizer'
require 'inflecto'

# Main Rom module with methods to setup and manage the environment
module Rom

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

end # module Rom

require 'rom/utils'
require 'rom/support/options'

require 'rom/repository'
require 'rom/environment'

require 'rom/attribute'
require 'rom/attribute/primitive'
require 'rom/attribute/embedded_value'
require 'rom/attribute/embedded_collection'
require 'rom/attribute/coercible'
require 'rom/attribute_set'

require 'rom/mapper'
require 'rom/mapper/builder'
require 'rom/mapper/registry'

require 'rom/relationship'
require 'rom/relationship/join_definition'
require 'rom/relationship/via_definition'
require 'rom/relationship/collection_behavior'
require 'rom/relationship/iterator'
require 'rom/relationship/iterator/tuples'
require 'rom/relationship/one_to_many'
require 'rom/relationship/one_to_one'
require 'rom/relationship/many_to_one'
require 'rom/relationship/many_to_many'
require 'rom/relationship/builder/belongs_to'
require 'rom/relationship/builder/has'

require 'rom/relation/header'
require 'rom/relation/header/attribute_index'
require 'rom/relation/header/relation_index'
require 'rom/relation/header/attribute'
require 'rom/relation/header/join_strategy'
require 'rom/relation/header/join_strategy/natural_join'
require 'rom/relation/header/join_strategy/inner_join'
require 'rom/relation/graph'
require 'rom/relation/graph/node'
require 'rom/relation/graph/node/name'
require 'rom/relation/graph/node/name_set'
require 'rom/relation/graph/edge'
require 'rom/relation/graph/connector'
require 'rom/relation/graph/connector/builder'
require 'rom/relation/mapper'
require 'rom/relation/mapper/relationship_set'
require 'rom/relation/mapper/builder'

require 'rom/query'
require 'rom/model'

require 'rom/finalizer'
require 'rom/finalizer/base_relation_mappers_finalizer'
require 'rom/finalizer/relationship_mappers_finalizer'
