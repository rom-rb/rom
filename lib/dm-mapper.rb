# Main DataMapper module with methods to setup and manage the environment
module DataMapper

  # Represent an undefined argument
  Undefined = Object.new.freeze

  # Represent a positive, infinitely large Float number
  Infinity  = 1.0 / 0

  # Setup a connection with a database
  #
  # @example
  #   DataMapper.setup(:default, 'postgres://localhost/test')
  #
  # @param [String, Symbol, #to_sym] name
  #   the repository name
  # @param [String] uri
  #   the database connection URI
  # @param [Engine] engine
  #   the backend engine that should be used for mappers
  #
  # @return [self]
  #
  # @api public
  def self.setup(name, uri, engine = Engine::VeritasEngine)
    engines[name.to_sym] = engine.new(uri)
    self
  end

  # Returns hash with all engines that were initialized
  #
  # @example
  #   DataMapper.engines # => {:default=>#<Engine::VeritasEngine:0x108168bf0..>}
  #
  # @return [Hash<Symbol, Engine>]
  #   a hash mapping a repository name to the engine used for that name
  #
  # @api public
  def self.engines
    @engines ||= {}
  end

  # Generates mappers class
  #
  # @see Mapper::Builder::Class.create
  #
  # @example
  #
  #   class User
  #     include DataMapper::Model
  #
  #     attribute :id,   Integer
  #     attribute :name, String
  #   end
  #
  #   DataMapper.build(User, :default) do
  #     key :id
  #   end
  #
  # @param [Model, ::Class(.name, .attribute_set)] model
  #   the model used by the generated mapper
  #
  # @param [Symbol] repository
  #   the repository name to use for the generated mapper
  #
  # @param [Proc, nil] &block
  #   a block to be class_eval'ed in the context of the generated mapper
  #
  # @return [Mapper::Relation]
  #
  # @api public
  def self.build(model, repository, &block)
    Mapper::Builder::Class.create(model, repository, &block)
  end

  # Finalize the environment after all mappers were defined
  #
  # @see Finalizer#run
  #
  # @example
  #
  #   DataMapper.finalize
  #
  # @return [self]
  #
  # @api public
  def self.finalize
    return self if @finalized
    Finalizer.call
    @finalized = true
    self
  end

  # @see Mapper.[]
  #
  # @api public
  def self.[](model)
    Mapper[model]
  end

  # @see Mapper.mapper_registry
  #
  # @api public
  def self.mapper_registry
    Mapper.mapper_registry
  end

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

require 'descendants_tracker'
require 'equalizer'
require 'inflector'

require 'data_mapper/support/graph'
require 'data_mapper/support/utils'

require 'data_mapper/engine'
require 'data_mapper/engine/arel_engine'
require 'data_mapper/engine/veritas_engine'

require 'data_mapper/relation_registry'
require 'data_mapper/relation_registry/relation_node'
require 'data_mapper/relation_registry/relation_node/arel_relation'
require 'data_mapper/relation_registry/relation_node/veritas_relation'
require 'data_mapper/relation_registry/relation_edge'
require 'data_mapper/relation_registry/relation_edge/arel_edge'
require 'data_mapper/relation_registry/relation_edge/veritas_edge'
require 'data_mapper/relation_registry/builder'
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
require 'data_mapper/mapper/relation/aliases'
require 'data_mapper/mapper/relation'

require 'data_mapper/mapper/builder'
require 'data_mapper/mapper/builder/class'

require 'data_mapper/relationship'
require 'data_mapper/relationship/join_definition'
require 'data_mapper/relationship/via_definition'
require 'data_mapper/relationship/collection_behavior'
require 'data_mapper/relationship/one_to_many'
require 'data_mapper/relationship/one_to_many/iterator'
require 'data_mapper/relationship/one_to_one'
require 'data_mapper/relationship/many_to_one'
require 'data_mapper/relationship/many_to_many'

require 'data_mapper/relationship/builder/belongs_to'
require 'data_mapper/relationship/builder/has'

require 'data_mapper/query'
require 'data_mapper/model'

require 'data_mapper/finalizer'
require 'data_mapper/finalizer/base_relation_mappers_finalizer'
require 'data_mapper/finalizer/relationship_mappers_finalizer'
