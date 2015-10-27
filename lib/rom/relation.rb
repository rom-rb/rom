require 'rom/support/deprecations'
require 'rom/relation/class_interface'

require 'rom/pipeline'
require 'rom/mapper_registry'

require 'rom/relation/loaded'
require 'rom/relation/curried'
require 'rom/relation/composite'
require 'rom/relation/graph'
require 'rom/relation/materializable'

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
    extend Deprecations
    extend ClassInterface
    extend ROM::Support::GuardedInheritanceHook

    include Options
    include Equalizer.new(:dataset)
    include Materializable
    include Pipeline

    option :mappers, reader: true, default: proc { MapperRegistry.new }

    # Dataset used by the relation
    #
    # This object is provided by the gateway during the setup
    #
    # @return [Object]
    #
    # @api private
    attr_reader :dataset

    # @api private
    def initialize(dataset, options = EMPTY_HASH)
      @dataset = dataset
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

    # Point a relation to a custom gateway
    #
    # @return A new relation targeting the new gateway
    #
    # @api public
    def from(gateway)
      __new__(gateway.dataset(self.class.name))
    end

    # Return if this relation is curried
    #
    # @return [false]
    #
    # @api private
    def curried?
      false
    end

    # @api private
    def with(options)
      __new__(dataset, options)
    end
    deprecate :to_lazy, :with, "to_lazy is no longer needed"

    # @api public
    def relation
      Deprecations.announce("#relation", 'all relations are now lazy')
      self
    end

    private

    # @api private
    def __new__(dataset, new_opts = EMPTY_HASH)
      self.class.new(dataset, options.merge(new_opts))
    end
  end
end
