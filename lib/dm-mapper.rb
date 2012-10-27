module DataMapper

  # Represent an undefined argument
  Undefined = Object.new.freeze

  Infinity  = 1.0 / 0

  # @api public
  def self.[](model)
    Mapper[model]
  end

  # @api public
  def self.mapper_registry
    Mapper.mapper_registry
  end

  # @api public
  def self.setup(name, uri, engine = Engine::VeritasEngine)
    engines[name.to_sym] = engine.new(uri)
  end

  # @api public
  def self.engines
    @engines ||= {}
  end

  # @api public
  def self.generate_mapper_for(model, repository, &block)
    Mapper::Builder::Class.create(model, repository, &block)
  end

  # @api public
  #
  # TODO: implement handling of dependencies between mappers
  def self.finalize
    Finalizer.run
    self
  end
end # module DataMapper

require 'veritas'
require 'veritas-optimizer'

require 'descendants_tracker'
require 'equalizer'

require 'inflector'
# TODO remove this once inflector includes it
require 'data_mapper/support/inflections'
require 'data_mapper/support/graph'
require 'data_mapper/support/utils'

require 'data_mapper/engine'
require 'data_mapper/engine/veritas_engine'

require 'data_mapper/alias_set'

require 'data_mapper/relation_registry'
require 'data_mapper/relation_registry/relation_node'
require 'data_mapper/relation_registry/relation_node/veritas_relation'
require 'data_mapper/relation_registry/relation_edge'
require 'data_mapper/relation_registry/builder'
require 'data_mapper/relation_registry/builder/base_builder'
require 'data_mapper/relation_registry/builder/via_builder'
require 'data_mapper/relation_registry/builder/node_name'
require 'data_mapper/relation_registry/builder/node_name_set'
require 'data_mapper/relation_registry/connector'

require 'data_mapper/mapper_registry'

require 'data_mapper/mapper/relationship_set'
require 'data_mapper/mapper/attribute'
require 'data_mapper/mapper/attribute/primitive'
require 'data_mapper/mapper/attribute/embedded_value'
require 'data_mapper/mapper/attribute/embedded_collection'
require 'data_mapper/mapper/attribute_set'
require 'data_mapper/mapper'
require 'data_mapper/mapper/relation'
require 'data_mapper/mapper/relation/base'

require 'data_mapper/mapper/builder'
require 'data_mapper/mapper/builder/class'

require 'data_mapper/relationship'
require 'data_mapper/relationship/options'
require 'data_mapper/relationship/options/one_to_one'
require 'data_mapper/relationship/options/one_to_many'
require 'data_mapper/relationship/options/many_to_one'
require 'data_mapper/relationship/options/many_to_many'
require 'data_mapper/relationship/options/validator'
require 'data_mapper/relationship/options/validator/one_to_one'
require 'data_mapper/relationship/options/validator/one_to_many'
require 'data_mapper/relationship/options/validator/many_to_one'
require 'data_mapper/relationship/options/validator/many_to_many'
require 'data_mapper/relationship/builder'
require 'data_mapper/relationship/builder/belongs_to'
require 'data_mapper/relationship/builder/has'
require 'data_mapper/relationship/one_to_one'
require 'data_mapper/relationship/one_to_many'
require 'data_mapper/relationship/many_to_one'
require 'data_mapper/relationship/many_to_many'

require 'data_mapper/query'
require 'data_mapper/model'

require 'data_mapper/finalizer'
