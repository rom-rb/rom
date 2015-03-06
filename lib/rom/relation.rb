require 'rom/relation/class_interface'

require 'rom/relation/lazy'
require 'rom/relation/curried'

module ROM
  # Base relation class
  #
  # Relation is a proxy for the dataset object provided by the repository. It
  # forwards every method to the dataset, which is why the "native" interface of
  # the underlying repository is available in the relation. This interface,
  # however, is considered private and should not be used outside of the
  # relation instance.
  #
  # ROM builds sub-classes of this class for every relation defined in the env
  # for easy inspection and extensibility - every repository can provide extensions
  # for those sub-classes but there is always a vanilla relation instance stored
  # in the schema registry.
  #
  # @api public
  class Relation
    extend ClassInterface

    include Options
    include Equalizer.new(:dataset)

    # Dataset used by the relation
    #
    # This object is provided by the repository during the setup
    #
    # @return [Object]
    #
    # @api private
    attr_reader :dataset

    # @api private
    def initialize(dataset, options = {})
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

    # Materialize a relation into an array
    #
    # @return [Array<Hash>]
    #
    # @api public
    def to_a
      to_enum.to_a
    end

    # Turn relation into a lazy-loadable and composable relation
    #
    # @see Lazy
    #
    # @return [Lazy]
    #
    # @api public
    def to_lazy(*args)
      Lazy.new(self, *args)
    end

    private

    # @api private
    def __new__(dataset, new_opts = {})
      self.class.new(dataset, options.merge(new_opts))
    end
  end
end
