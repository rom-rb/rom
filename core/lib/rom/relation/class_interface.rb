require 'set'

require 'dry/core/inflector'
require 'dry/core/constants'

require 'rom/relation/name'
require 'rom/relation/view_dsl'
require 'rom/schema'

module ROM
  class Relation
    # @api public
    module ClassInterface
      include Dry::Core::Constants

      DEFAULT_DATASET_PROC = -> * { self }.freeze

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

        klass.defines :adapter

        # Extend with functionality required by adapters *only* if this is a direct
        # descendant of an adapter-specific relation subclass
        return unless respond_to?(:adapter) && klass.superclass == ROM::Relation[adapter]

        if instance_variable_defined?(:@schema)
          klass.instance_variable_set(:@schema, @schema)
        end

        klass.class_eval do
          # Set or get custom dataset block
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
          def self.dataset(&block)
            if defined?(@dataset)
              @dataset
            else block
              @dataset = block || DEFAULT_DATASET_PROC
            end
          end
        end
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
      def schema(dataset = nil, as: nil, infer: false, &block)
        if defined?(@schema) && !block && !infer
          @schema
        elsif block || infer
          ds_name = schema_opts.fetch(:dataset, dataset || default_name.dataset)
          relation = as || ds_name || default_name.relation

          name = Name[relation, dataset]
          inferrer = infer ? schema_inferrer : nil

          unless schema_class
            raise MissingSchemaClassError.new(self)
          end

          dsl = schema_dsl.new(
            name,
            schema_class: schema_class, attr_class: schema_attr_class, inferrer: inferrer,
            &block
          )

          @schema = dsl.call
        end
      end

      # Define a relation view with a specific schema
      #
      # Explicit relation views allow relation composition with auto-mapping
      # in repositories. It's useful for cases like defining custom views
      # for associations where relations (even from different databases) can
      # be composed together and automatically mapped in memory to structs.
      #
      # @overload view(name, schema, &block)
      #   @example View with the canonical schema
      #     class Users < ROM::Relation[:sql]
      #       view(:listing, schema) do
      #         order(:name)
      #       end
      #     end
      #
      #   @example View with a projected schema
      #     class Users < ROM::Relation[:sql]
      #       view(:listing, schema.project(:id, :name)) do
      #         order(:name)
      #       end
      #     end
      #
      # @overload view(name, &block)
      #   @example View with the canonical schema and arguments
      #     class Users < ROM::Relation[:sql]
      #       view(:by_name) do |name|
      #         where(name: name)
      #       end
      #     end
      #
      #   @example View with projected schema and arguments
      #     class Users < ROM::Relation[:sql]
      #       view(:by_name) do
      #         schema { project(:id, :name) }
      #         relation { |name| where(name: name) }
      #       end
      #     end
      #
      #   @example View with a schema extended with foreign attributes
      #     class Users < ROM::Relation[:sql]
      #       view(:index) do
      #         schema { append(relations[:tasks][:title]) }
      #         relation { |name| where(name: name) }
      #       end
      #     end
      #
      # @return [Symbol] view method name
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

        schemas[name] =
          if args.size == 2
            schema.project(*args[1])
          else
            new_schema_fn
          end

        if relation_block.arity > 0
          auto_curry_guard do
            define_method(name, &relation_block)

            auto_curry(name) do
              schemas[name].(self)
            end
          end
        else
          define_method(name) do
            schemas[name].(instance_exec(&relation_block))
          end
        end

        name
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

      # @api private
      def curried
        Curried
      end

      # @api private
      def view_methods
        ancestor_methods = ancestors.reject { |klass| klass == self }
          .map(&:instance_methods).flatten(1)

        instance_methods - ancestor_methods + auto_curried_methods
      end

      # @api private
      def schemas
        @schemas ||= {}
      end

      # Return default relation name used in schemas
      #
      # @return [Name]
      #
      # @api private
      def default_name
        Name[Dry::Core::Inflector.underscore(name).tr('/', '_').to_sym]
      end

      # @api private
      def default_schema(klass = self)
        klass.schema || klass.schema_class.define(klass.default_name)
      end

      # @api private
      def name
        super || superclass.name
      end

      # Hook to finalize a relation after its instance was created
      #
      # @api private
      def finalize(registry, relation)
        schemas = relation.schemas.reduce({}) do |h, (a, e)|
          h.update(a => e.is_a?(Proc) ? instance_exec(registry, &e) : e)
        end
        relation.schemas.update(schemas)
        relation
      end
    end
  end
end
