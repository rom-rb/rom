require 'set'

require 'dry/core/inflector'
require 'rom/support/class_macros'
require 'rom/auto_curry'
require 'rom/relation/curried'
require 'rom/relation/name'
require 'rom/relation/view_dsl'
require 'rom/schema'

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

        if respond_to?(:adapter) && adapter.nil?
          raise MissingAdapterIdentifierError,
                "relation class +#{self}+ is missing the adapter identifier"
        end

        klass.extend ClassMacros
        klass.defines :adapter

        # Extend with functionality required by adapters *only* if this is a direct
        # descendant of an adapter-specific relation subclass
        return unless respond_to?(:adapter) && klass.superclass == ROM::Relation[adapter]

        klass.class_eval do
          use :registry_reader

          defines :gateway, :dataset, :dataset_proc, :register_as,
                  :schema_dsl, :schema_inferrer

          gateway :default
          schema_dsl Schema::DSL
          schema_inferrer nil

          dataset default_name

          # Relation's dataset name
          #
          # In example a table name in an SQL database
          #
          # @return [Symbol]
          #
          # @api public
          attr_reader :name

          # Set dataset name
          #
          # If a block is passed it will be evaluated in the context of the dataset
          # to define the default dataset which will be injected into a relation
          # when setting up relation registry
          #
          # @example
          #   class Relations::Users < ROM::Relation[:memory]
          #     dataset :users
          #   end
          #
          #   class Users < ROM::Relation[:memory]
          #     dataset { sort_by(:id) }
          #   end
          #
          # @param [Symbol] value The name of the dataset
          #
          # @api public
          def self.dataset(value = ClassMacros::UndefinedValue, &block)
            dataset_proc(block) if block
            super
          end

          # Set or get name under which a relation will be registered
          #
          # This defaults to `dataset` or `default_name` for descendant relations
          #
          # @return [Symbol]
          #
          # @api public
          def self.register_as(value = ClassMacros::UndefinedValue)
            if value == ClassMacros::UndefinedValue
              return @register_as if defined?(@register_as)

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

          # @api private
          def initialize(dataset, options = EMPTY_HASH)
            @name = Name.new(self.class.register_as, self.class.dataset)
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

      # Specify canonical schema for a relation
      #
      # With a schema defined commands will set up a type-safe input handler
      # automatically
      #
      # @example
      #   class Users < ROM::Relation[:sql]
      #     schema do
      #       attribute :id, Types::Serial
      #       attribute :name, Types::String
      #     end
      #   end
      #
      #   # access schema
      #   Users.schema
      #
      # @return [Schema]
      #
      # @param [Symbol] dataset An optional dataset name
      # @param [Boolean] infer Whether to do an automatic schema inferring
      #
      # @api public
      def schema(dataset = nil, infer: false, &block)
        if defined?(@schema)
          @schema
        elsif block || infer
          self.dataset(dataset) if dataset
          self.register_as(self.dataset) unless register_as

          name = Name[register_as, self.dataset]
          inferrer = infer ? schema_inferrer : nil
          dsl = schema_dsl.new(name, inferrer, &block)

          @schema = dsl.call
        end
      end

      # Define a relation view with a specific header
      #
      # With headers defined all the mappers will be inferred automatically
      #
      # @example
      #   class Users < ROM::Relation[:sql]
      #     view(:by_name, [:id, :name]) do |name|
      #       where(name: name)
      #     end
      #
      #     view(:listing, [:id, :name, :email]) do
      #       select(:id, :name, :email).order(:name)
      #     end
      #   end
      #
      # @api public
      def view(*args, &block)
        if args.size == 1 && block.arity > 0
          raise ArgumentError, "header must be set as second argument"
        end

        name, new_schema_fn, relation_block =
          if args.size == 1
            ViewDSL.new(*args, schema, &block).call
          else
            [*args, block]
          end

        attributes[name] =
          if args.size == 2
            schema.project(*args[1])
          else
            new_schema_fn
          end

        if relation_block.arity > 0
          auto_curry_guard do
            define_method(name, &relation_block)

            auto_curry(name) do
              self.class.attributes[name].(self).with(view: name)
            end
          end
        else
          define_method(name) do
            relation = instance_exec(&relation_block)
            self.class.attributes[name].(relation).with(view: name)
          end
        end
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
              new(dataset.__send__(:#{method}, *args, &block))
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
        Dry::Core::Inflector.underscore(name).tr('/', '_').to_sym
      end

      # @api private
      def curried
        Curried
      end

      # @api private
      def view_methods
        ancestor_methods = ancestors.reject { |klass| klass == self }
          .map(&:instance_methods).flatten

        instance_methods - ancestor_methods + auto_curried_methods
      end

      # @api private
      def attributes
        @attributes ||= {}
      end

      # Hook to finalize a relation after its instance was created
      #
      # @api private
      def finalize(_container, relation)
        attributes = relation.class.attributes.reduce({}) do |h, (a, e)|
          h.update(a => e.is_a?(Proc) ? instance_exec(&e) : e)
        end
        relation.class.attributes.update(attributes)
        relation
      end

      # @api private
      def schema_defined!
        # @!method base
        #   Return the base relation with default attributes
        #   @return [Relation]
        #   @api public
        view(:base, schema.map(&:name)) do
          self
        end
      end
    end
  end
end
