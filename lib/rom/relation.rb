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
    extend ClassMacros

    include Charlatan.new(:dataset)
    include Equalizer.new(:dataset)

    defines :repository, :base_name, :register_as

    repository :default

    attr_reader :name, :dataset, :__registry__

    def self.inherited(klass)
      super
      klass.base_name(klass.default_name)
    end

    def self.[](type)
      ROM.adapters.fetch(type).const_get(:Relation)
    end

    def self.register_as(value = Undefined)
      super || base_name
    end

    def self.default_name
      return unless name
      Inflecto.underscore(name).gsub('/', '_').to_sym
    end

    def self.registry(repositories)
      registry = {}
      descendants = self.descendants

      descendants.each do |klass|
        repository = repositories[klass.repository]
        dataset = repository.dataset(klass.base_name)

        relation = klass.new(dataset, registry)
        repository.extend_relation_instance(relation)

        name = klass.register_as

        if registry.key?(name)
          raise RelationAlreadyDefinedError,
            "Relation with `register_as #{name.inspect}` registered more " \
            "than once"
        end

        registry[name] = relation
      end

      registry.each_value do |relation|
        relation.class.finalize(registry, relation)
      end

      registry
    end

    # @api private
    def initialize(dataset, registry = {})
      super
      @dataset = dataset
      @name = self.class.base_name
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
