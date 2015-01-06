module ROM
  # Base relation class
  #
  # Relation is a proxy for the dataset object provided by the adapter, it
  # forwards every method to the dataset that's why "native" interface of the
  # underlying adapter is available in the relation. This interface, however, is
  # considered private and should not be used outside of the relation instance.
  #
  # ROM builds sub-classes of this class for every relation defined in the env
  # for easy inspection and extensibility - every adapter can provide extensions
  # for those sub-classes but there is always a vanilla relation instance stored
  # in the schema registry.
  #
  # Relation instances also have access to the experimental ROM::RA interface
  # giving in-memory relational operations that are very handy, especially when
  # dealing with joined relations or data coming from different sources.
  #
  # @api public
  class Relation
    include Charlatan.new(:dataset)
    include Equalizer.new(:dataset)

    attr_reader :dataset

    class << self
      # Relation methods that were defined inside setup.relation DSL
      #
      # @return [Array<Symbol>]
      #
      # @api private
      attr_accessor :relation_methods
    end

    # Hook to finalize a relation after its instance was created
    #
    # @api private
    def self.finalize(_env, _relation)
      # noop
    end

    # Yield dataset tuples
    #
    # @yield [Hash]
    #
    # @api private
    def each(&block)
      return to_enum unless block
      dataset.each(&block)
    end
  end
end
