require 'set'

require 'rom/support/auto_curry'
require 'rom/relation/curried'

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

        if respond_to?(:adapter) && adapter.nil?
          raise MissingAdapterIdentifierError,
            "relation class +#{self}+ is missing the adapter identifier"
        end

        # Extend with functionality required by adapters *only* if this is a direct
        # descendant of an adapter-specific relation subclass
        return unless respond_to?(:adapter) && klass.superclass == ROM::Relation[adapter]

        klass.class_eval do
          use :registry_reader

          defines :gateway, :dataset, :register_as

          deprecate_class_method :repository, :gateway
          deprecate :repository, :gateway

          gateway :default

          dataset default_name

          # Relation's dataset name
          #
          # In example a table name in an SQL database
          #
          # @return [Symbol]
          #
          # @api public
          attr_reader :name

          # Set or get name under which a relation will be registered
          #
          # This defaults to `dataset` or `default_name` for descendant relations
          #
          # @return [Symbol]
          #
          # @api public
          def self.register_as(value = Undefined)
            if value == Undefined
              super_val = super()

              if superclass == ROM::Relation[adapter]
                super_val || dataset
              else
                super_val == dataset ? default_name : super_val
              end
            else
              super
            end
          end

          # @api public
          def self.exposed_relations(*args)
            Deprecations.announce("#{self}.exposed_relations", 'this method has no effect anymore')
            Set.new
          end

          # @api private
          def initialize(dataset, options = EMPTY_HASH)
            @name = self.class.dataset
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

        klass.extend(AutoCurry)
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
      def [](adapter)
        ROM.adapters.fetch(adapter).const_get(:Relation)
      rescue KeyError
        raise AdapterNotPresentError.new(adapter, :relation)
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
      def use(plugin, _options = EMPTY_HASH)
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

      # @api private
      def curried
        Curried
      end

      # Hook to finalize a relation after its instance was created
      #
      # @api private
      def finalize(_container, _relation)
        # noop
      end
    end
  end
end
