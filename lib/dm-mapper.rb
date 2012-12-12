# Main DataMapper module with methods to setup and manage the environment
module DataMapper

  # Represent an undefined argument
  Undefined = Object.new.freeze

  # Represent a positive, infinitely large Float number
  Infinity  = 1.0 / 0

end # module DataMapper

require 'abstract_type'

# TODO merge this into abstract_class and add specs
module AbstractType
  def self.included(descendant)
    super
    descendant.instance_variable_set(:@descendant_superclass, descendant.superclass)
    descendant.extend(ClassMethods)
    self
  end

  module ClassMethods

    def new(*)
      if superclass.equal?(@descendant_superclass)
        raise NotImplementedError, "#{self} is an abstract class"
      else
        super
      end
    end
  end
end

require 'bigdecimal'
require 'date'

require 'descendants_tracker'
require 'equalizer'
require 'inflector'

require 'data_mapper/utils'

require 'data_mapper/environment'

require 'data_mapper/mapper/relationship_set'
require 'data_mapper/mapper/attribute'
require 'data_mapper/mapper/attribute/primitive'
require 'data_mapper/mapper/attribute/embedded_value'
require 'data_mapper/mapper/attribute/association'
require 'data_mapper/mapper/attribute/embedded_collection'
require 'data_mapper/mapper/attribute_set'
require 'data_mapper/mapper'
require 'data_mapper/mapper/builder'
require 'data_mapper/mapper/registry'

require 'data_mapper/relationship'
require 'data_mapper/relationship/join_definition'
require 'data_mapper/relationship/via_definition'
require 'data_mapper/relationship/collection_behavior'
require 'data_mapper/relationship/iterator'
require 'data_mapper/relationship/iterator/tuples'
require 'data_mapper/relationship/one_to_many'
require 'data_mapper/relationship/one_to_one'
require 'data_mapper/relationship/many_to_one'
require 'data_mapper/relationship/many_to_many'
require 'data_mapper/relationship/builder/belongs_to'
require 'data_mapper/relationship/builder/has'

require 'data_mapper/relation/graph'
require 'data_mapper/relation/graph/node/aliases'
require 'data_mapper/relation/graph/node/aliases/unary'
require 'data_mapper/relation/graph/node/aliases/binary'
require 'data_mapper/relation/graph/node'
require 'data_mapper/relation/graph/node/name'
require 'data_mapper/relation/graph/node/name_set'
require 'data_mapper/relation/graph/edge'
require 'data_mapper/relation/graph/connector'
require 'data_mapper/relation/graph/connector/builder'
require 'data_mapper/relation/mapper'
require 'data_mapper/relation/mapper/builder'

require 'data_mapper/query'
require 'data_mapper/model'

require 'data_mapper/finalizer'
require 'data_mapper/finalizer/base_relation_mappers_finalizer'
require 'data_mapper/finalizer/relationship_mappers_finalizer'
