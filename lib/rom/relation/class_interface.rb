require 'set'

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

        klass.extend ClassMacros
        klass.extend Deprecations
        klass.defines :adapter

        return if klass.superclass == ROM::Relation

        klass.class_eval do
          use :registry_reader

          defines :gateway, :dataset, :register_as, :exposed_relations

          deprecate_class_method :repository, :gateway
          deprecate :repository, :gateway

          gateway :default

          dataset(default_name)
          exposed_relations Set.new

          # Relation's dataset name
          #
          # In example a table name in an SQL database
          #
          # @return [Symbol]
          #
          # @api public
          attr_reader :name

          # A set with public method names that return "virtual" relations
          #
          # Only those methods are exposed directly on relations return by
          # Env#relation interface
          #
          # @return [Set]
          #
          # @api private
          attr_reader :exposed_relations

          # Set or get name under which a relation will be registered
          #
          # This defaults to `dataset` name
          #
          # @return [Symbol]
          #
          # @api public
          def self.register_as(value = Undefined)
            if value == Undefined
              super() || dataset
            else
              super
            end
          end

          # Hook used to collect public method names
          #
          # @api private
          def self.method_added(name)
            super
            exposed_relations << name if public_instance_methods.include?(name)
          end

          # @api private
          def initialize(dataset, options = {})
            @name = self.class.dataset
            @exposed_relations = self.class.exposed_relations
            super
          end

          # Return name of the source gateway of this relation
          #
          # @return [Symbol]
          #
          # @api private
          def gateway
            self.class.gateway
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

      # Include a registered plugin in this relation class
      #
      # @param [Symbol] plugin
      # @param [Hash] options
      # @option options [Symbol] :adapter (:default) first adapter to check for plugin
      #
      # @api public
      def use(plugin, _options = {})
        ROM.plugin_registry.relations.fetch(plugin, adapter).apply_to(self)
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
      # @param [Hash] gateways
      # @param [Array] descendants a list of relation descendants
      #
      # @return [Hash]
      #
      # @api private
      def registry(gateways, descendants)
        registry = {}

        descendants.each do |klass|
          # TODO: raise a meaningful error here and add spec covering the case
          #       where klass' gateway points to non-existant repo
          gateway = gateways.fetch(klass.gateway)
          dataset = gateway.dataset(klass.dataset)

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
