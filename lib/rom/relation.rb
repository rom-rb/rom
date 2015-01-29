require 'rom/relation/dsl'

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
  # Relation instances also have access to the experimental ROM::RA interface
  # giving in-memory relational operations that are very handy, especially when
  # dealing with joined relations or data coming from different sources.
  #
  # @api public
  class Relation
    extend DescendantsTracker

    include Charlatan.new(:dataset)
    include Equalizer.new(:dataset)

    attr_reader :name, :dataset, :__registry__

    def self.inherited(klass)
      klass.class_eval do
        include DSL

        defines :repository, :base_name

        repository :default

        def initialize(dataset, registry = {})
          super
          @name = self.class.base_name
        end
      end
      super
    end

    def self.[](type)
      Relation.repository_classes.fetch(type) do
        adapter = ROM.adapters.fetch(type)
        ext = adapter.const_get(:Relation) if adapter.const_defined?(:Relation)

        klass = Class.new(self)
        klass.send(:include, ext) if ext

        Relation.repository_classes[type] = klass

        klass
      end
    end

    def self.repository_classes
      @__repository_classes__ ||= {}
    end

    # @api private
    def self.build_class(name, options = {})
      class_name = "ROM::Relation[#{Inflecto.camelize(name)}]"
      adapter = options.fetch(:adapter)

      ClassBuilder.new(name: class_name, parent: self[adapter]).call do |klass|
        klass.repository(options.fetch(:repository) { :default })
        klass.base_name(name)
      end
    end

    # @api private
    def initialize(dataset, registry = {})
      super
      @dataset = dataset
      @__registry__ = registry
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

    # Materialize relation into an array
    #
    # @return [Array<Hash>]
    #
    # @api public
    def to_a
      to_enum.to_a
    end

    # @api private
    def exposed_relations
      public_methods - dataset.public_methods - [:name, :dataset, :__registry__]
    end

    # @api private
    def repository
      self.class.repository
    end

    # @api private
    def respond_to_missing?(name, _include_private = false)
      __registry__.key?(name) || super
    end

    private

    def method_missing(name, *)
      __registry__.fetch(name) { super }
    end
  end
end
