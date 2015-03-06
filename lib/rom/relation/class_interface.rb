require 'rom/relation/registry_reader'

module ROM
  class Relation
    module ClassInterface
      # Register adapter relation subclasses during setup phase
      #
      # In adition those subclasses are extended with an interface for accessing
      # relation registry and to define `register_as` setting
      #
      # @api private
      def inherited(klass)
        super

        return if klass.superclass == ROM::Relation

        klass.class_eval do
          extend ClassMacros
          include RegistryReader

          defines :repository, :dataset, :register_as, :exposed_relations

          repository :default

          dataset(default_name)
          exposed_relations Set.new

          attr_reader :name, :exposed_relations

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

          def initialize(dataset, options = {})
            @name = self.class.dataset
            @exposed_relations = self.class.exposed_relations
            super
          end

          # @api private
          def repository
            self.class.repository
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
      def [](type)
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
      def forward(*methods)
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
      def default_name
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
      def registry(repositories, descendants)
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

      # Hook to finalize a relation after its instance was created
      #
      # @api private
      def finalize(_env, _relation)
        # noop
      end
    end
  end
end
