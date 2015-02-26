require 'set'
require 'rom/relation/registry_reader'
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
  # Relation instances also have access to the experimental ROM::RA interface
  # giving in-memory relational operations that are very handy, especially when
  # dealing with joined relations or data coming from different sources.
  #
  # @api public
  class Relation
    extend ClassMacros

    include Options
    include Equalizer.new(:dataset)

    defines :repository, :dataset, :register_as, :exposed_relations

    repository :default

    attr_reader :name, :dataset, :exposed_relations

    # Register adapter relation subclasses during setup phase
    #
    # In adition those subclasses are extended with an interface for accessing
    # relation registry and to define `register_as` setting
    #
    # @api private
    def self.inherited(klass)
      super

      return if self == ROM::Relation

      klass.class_eval do
        include ROM::Relation::RegistryReader

        dataset(default_name)
        exposed_relations Set.new

        def self.register_as(value = Undefined)
          if value == Undefined
            @register_as || dataset
          else
            super
          end
        end

        def self.method_added(name)
          super
          exposed_relations << name if public_instance_methods.include?(name)
        end
      end

      ROM.register_relation(klass)
    end

    # Return adapter-specific relation subclass
    #
    # @example
    #   ROM::Relation[:memory]
    #   # => ROM::Memory::Relation
    #
    # @return [Class]
    #
    # @api public
    def self.[](type)
      ROM.adapters.fetch(type).const_get(:Relation)
    end

    # Dynamically define a method that will forward to the dataset and wrap
    # response in the relation itself
    #
    # @example
    #   class SomeAdapterRelation < ROM::Relation
    #     forward :super_query
    #   end
    #
    # @api public
    def self.forward(*methods)
      methods.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(*args, &block)
            __new__(dataset.__send__(:#{method}, *args, &block))
          end
        RUBY
      end
    end

    # Return default relation name used for `register_as` setting
    #
    # @return [Symbol]
    #
    # @api private
    def self.default_name
      return unless name
      Inflector.underscore(name).gsub('/', '_').to_sym
    end

    # Build relation registry of specified descendant classes
    #
    # This is used by the setup
    #
    # @param [Hash] repositories
    # @param [Array] descendants a list of relation descendants
    #
    # @return [Hash]
    #
    # @api private
    def self.registry(repositories, descendants)
      registry = {}

      descendants.each do |klass|
        # TODO: raise a meaningful error here and add spec covering the case
        #       where klass' repository points to non-existant repo
        repository = repositories.fetch(klass.repository)
        dataset = repository.dataset(klass.dataset)

        relation = klass.new(dataset, __registry__: registry)

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
    def initialize(dataset, options = {})
      @dataset = dataset
      @name = self.class.dataset
      @exposed_relations = self.class.exposed_relations
      super
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
      dataset.each { |tuple| yield(tuple) }
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
    def repository
      self.class.repository
    end

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
