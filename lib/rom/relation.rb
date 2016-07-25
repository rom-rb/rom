require 'rom/relation/class_interface'

require 'rom/pipeline'
require 'rom/mapper_registry'

require 'rom/relation/loaded'
require 'rom/relation/curried'
require 'rom/relation/composite'
require 'rom/relation/graph'
require 'rom/relation/materializable'

require 'rom/types'

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

    option :mappers, reader: true, default: proc { MapperRegistry.new }

    # @!attribute [r] schema_hash
    #   @return Tuple processing function, uses schema or defaults to Hash[]
    #   @api private
    option :schema_hash, reader: true, default: -> relation {
      relation.schema? ? Types::Coercible::Hash.schema(relation.schema.to_h) : Hash
    }

    # Dataset used by the relation
    #
    # This object is provided by the gateway during the setup
    #
    # @return [Object]
    #
    # @api private
    attr_reader :dataset

    # Return relation schema object (if defined)
    #
    # @return [Schema]
    #
    # @api public
    attr_reader :schema

    # @api private
    def initialize(dataset, options = EMPTY_HASH)
      @dataset = dataset
      @schema = self.class.schema
      super
    end

    # Yield dataset tuples
    #
    # @yield [Hash]
    #
    # @api private
    def each(&block)
      return to_enum unless block
      dataset.each { |tuple| yield(tuple) }
    end

    # Eager load other relation(s) for this relation
    #
    # @param [Array<Relation>] others The other relation(s) to eager load
    #
    # @return [Relation::Graph]
    #
    # @api public
    def combine(*others)
      Graph.build(self, others)
    end

    # Load relation
    #
    # @return [Relation::Loaded]
    #
    # @api public
    def call
      Loaded.new(self)
    end

    # Materialize a relation into an array
    #
    # @return [Array<Hash>]
    #
    # @api public
    def to_a
      to_enum.to_a
    end

    # Return if this relation is curried
    #
    # @return [false]
    #
    # @api private
    def curried?
      false
    end

    # Return if this relation is a graph
    #
    # @return [false]
    #
    # @api private
    def graph?
      false
    end

    # Return true if a relation has schema defined
    #
    # @return [TrueClass, FalseClass]
    #
    # @api private
    def schema?
      ! schema.nil?
    end

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
