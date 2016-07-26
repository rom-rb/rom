require 'rom/relation/class_interface'

require 'rom/pipeline'
require 'rom/mapper_registry'

require 'rom/relation/loaded'
require 'rom/relation/curried'
require 'rom/relation/composite'
require 'rom/relation/graph'
require 'rom/relation/materializable'
require 'rom/association_set'

require 'rom/types'
require 'rom/schema'

module ROM
  # Base relation class
  #
  # Relation is a proxy for the dataset object provided by the gateway. It
  # forwards every method to the dataset, which is why the "native" interface of
  # the underlying gateway is available in the relation. This interface,
  # however, is considered private and should not be used outside of the
  # relation instance.
  #
  # ROM builds sub-classes of this class for every relation defined in the
  # environment for easy inspection and extensibility - every gateway can
  # provide extensions for those sub-classes but there is always a vanilla
  # relation instance stored in the schema registry.
  #
  # @api public
  class Relation
    extend ClassInterface

    include Options
    include Dry::Equalizer(:dataset)
    include Materializable
    include Pipeline

    # @!attribute [r] mappers
    #   @return [MapperRegistry] an optional mapper registry (empty by default)
    option :mappers, reader: true, default: proc { MapperRegistry.new }

    # @!attribute [r] schema_hash
    #   @return [Object#[]] tuple processing function, uses schema or defaults to Hash[]
    #   @api private
    option :schema_hash, reader: true, default: -> relation {
      relation.schema? ? Types::Coercible::Hash.schema(relation.schema.to_h) : Hash
    }

    # @!attribute [r] associations
    #   @return [AssociationSet] Schema's association set (empty by default)
    option :associations, reader: true, default: -> rel {
      rel.schema? ? rel.schema.associations : Schema::EMPTY_ASSOCIATION_SET
    }

    # @!attribute [r] dataset
    #   @return [Object] dataset used by the relation provided by relation's gateway
    #   @api public
    attr_reader :dataset

    # @!attribute [r] schema
    #   @return [Schema] returns relation schema object (if defined)
    #   @api public
    attr_reader :schema

    # Initializes a relation object
    #
    # @param dataset [Object]
    #
    # @param options [Hash]
    #   @option :mappers [MapperRegistry]
    #   @option :schema_hash [#[]]
    #   @option :associations [AssociationSet]
    #
    # @api public
    def initialize(dataset, options = EMPTY_HASH)
      @dataset = dataset
      @schema = self.class.schema
      super
    end

    # Yields relation tuples
    #
    # @yield [Hash]
    # @return [Enumerator] if block is not provided
    #
    # @api public
    def each(&block)
      return to_enum unless block
      dataset.each { |tuple| yield(tuple) }
    end

    # Composes with other relations
    #
    # @param *others [Array<Relation>] The other relation(s) to compose with
    #
    # @return [Relation::Graph]
    #
    # @api public
    def combine(*others)
      Graph.build(self, others)
    end

    # Loads relation
    #
    # @return [Relation::Loaded]
    #
    # @api public
    def call
      Loaded.new(self)
    end

    # Materializes a relation into an array
    #
    # @return [Array<Hash>]
    #
    # @api public
    def to_a
      to_enum.to_a
    end

    # Returns if this relation is curried
    #
    # @return [false]
    #
    # @api private
    def curried?
      false
    end

    # Returns if this relation is a graph
    #
    # @return [false]
    #
    # @api private
    def graph?
      false
    end

    # Returns true if a relation has schema defined
    #
    # @return [TrueClass, FalseClass]
    #
    # @api private
    def schema?
      ! schema.nil?
    end

    # Returns a new instance with the same dataset but new options
    #
    # @param new_options [Hash]
    #
    # @return [Relation]
    #
    # @api private
    def with(new_options)
      __new__(dataset, options.merge(new_options))
    end

    private

    # @api private
    def __new__(dataset, new_opts = EMPTY_HASH)
      self.class.new(dataset, options.merge(new_opts))
    end

    # @api private
    def composite_class
      Relation::Composite
    end
  end
end
