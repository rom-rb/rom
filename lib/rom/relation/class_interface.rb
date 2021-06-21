# frozen_string_literal: true

require "set"

require "dry/effects"

require "rom/support/inflector"

require "rom/constants"
require "rom/components"
require "rom/relation/name"
require "rom/relation/view_dsl"
require "rom/schema"
require "rom/support/notifications"

module ROM
  class Relation
    # Global class-level API for relation classes
    #
    # @api public
    module ClassInterface
      extend Notifications::Listener

      include Components

      subscribe("configuration.relations.object.registered") do |event|
        relation = event[:relation]
        registry = event[:registry]

        schemas = relation.schemas.reduce({}) do |h, (a, e)|
          h.update(a => e.is_a?(Proc) ? relation.class.instance_exec(registry, &e) : e)
        end

        relation.schemas.update(schemas)
        relation
      end

      DEFAULT_DATASET_PROC = -> * { self }.freeze
      INVALID_RELATIONS_NAMES = %i[
        relations schema
      ].freeze

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

      # Set or get custom dataset block
      #
      # This block will be evaluated when a relation is instantiated and registered
      # in a relation registry.
      #
      # @example
      #   class Users < ROM::Relation[:memory]
      #     dataset { sort_by(:id) }
      #   end
      #
      # @api public
      def dataset(&block)
        if defined?(@dataset)
          @dataset
        else
          @dataset = block || DEFAULT_DATASET_PROC
        end
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
      #   # access schema from a finalized relation
      #   users.schema
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
          raise MissingSchemaClassError, self unless schema_class

          ds_name = dataset || schema_opts.fetch(:dataset, default_name.dataset)
          relation = as || schema_opts.fetch(:relation, ds_name)

          raise InvalidRelationName, relation if invalid_relation_name?(relation)

          # TODO: such legacy very wow - this should be removed eventually
          @relation_name = Name[relation, ds_name]

          schema_proc = proc do |**kwargs, &inner_block|
            schema_dsl.new(
              relation_name,
              schema_class: schema_class,
              attr_class: schema_attr_class,
              inferrer: schema_inferrer.with(enabled: infer),
              &block
            ).call(**kwargs, &inner_block)
          end

          # TODO: remove this eventually. Schemas are now evaluated using components
          #       during finalization, storing schema_proc is no longer needed
          @schema_proc = components.add(:schemas, proc: schema_proc, relation: self)
        end
      end
      # @api private
      attr_reader :schema_proc

      # Assign a schema to a relation class
      #
      # @param [Schema] schema
      #
      # @return [Schema]
      #
      # @api private
      def set_schema!(schema)
        @schema = schema
      end

      # @!attribute [r] relation_name
      #   @return [Name] Qualified relation name
      def relation_name
        raise MissingSchemaError, self unless defined?(@relation_name)

        @relation_name
      end

      # Define a relation view with a specific schema
      #
      # This method should only be used in cases where a given adapter doesn't
      # support automatic schema projection at run-time.
      #
      # **It's not needed in rom-sql**
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
          raise ArgumentError, "schema attribute names must be provided as the second argument"
        end

        name, new_schema_fn, relation_block =
          if args.size == 1
            ViewDSL.new(*args, schema, &block).call
          else
            [*args, block]
          end

        schemas[name] =
          if args.size == 2
            -> _ { schema.project(*args[1]) }
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
      def use(plugin, **options)
        ROM.plugin_registry[:relation].fetch(plugin, adapter).apply_to(self, **options)
      end

      # Build default mapper registry
      #
      # @return [MapperRegistry]
      #
      # @api private
      def mapper_registry(opts = EMPTY_HASH)
        adapter_ns = ROM.adapters[adapter]

        compiler =
          if adapter_ns&.const_defined?(:MapperCompiler)
            adapter_ns.const_get(:MapperCompiler)
          else
            MapperCompiler
          end

        MapperRegistry.new({}, compiler: compiler.new(**opts), **opts)
      end

      # @api private
      def command_registry(name)
        CommandRegistry.new({}, relation_name: name)
      end

      # @api private
      def curried
        Curried
      end

      # @api private
      def view_methods
        ancestor_methods = ancestors.reject { |klass| klass == self }
          .map(&:instance_methods).flatten(1)

        instance_methods - ancestor_methods + auto_curried_methods.to_a
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
      def default_name(inflector = Inflector)
        Name[inflector.underscore(name).tr("/", "_").to_sym]
      end

      # @api private
      def default_schema(klass = self, inflector: Inflector)
        klass.schema ||
          if (schema_comp = klass.components.schemas.detect { |c| c.relation == klass })
            klass.set_schema!(schema_comp.(inflector: inflector))
          else
            klass.schema_class.define(klass.default_name)
          end
      end

      # @api private
      def name
        super || superclass.name
      end

      private

      def invalid_relation_name?(relation)
        INVALID_RELATIONS_NAMES.include?(relation.to_sym)
      end
    end
  end
end
