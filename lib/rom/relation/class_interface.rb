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
      def dataset(id = nil, **options, &block)
        components.replace(:datasets, id: id, provider: self, block: block, **options)
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
      # @param [Boolean, Symbol] view Whether this is a view schema
      #
      # @api public
      INVALID_IDS = %i[relations schema].freeze

      def schema(id = nil, view: false, **options, &block)
        if view
          components.add(
            :schemas, id: view, view: true, provider: self, name: Name[view], **options, block: block
          )
        else
          component = components.replace(
            :schemas, id: id, provider: self, **options, block: block
          )

          raise MissingSchemaClassError, self unless schema_class

          # TODO: this can go away by simply skipping readers in case of clashes
          raise InvalidRelationName, id if INVALID_IDS.include?(component.id)

          if components.datasets(id: component.name.dataset).empty?
            dataset(component.name.dataset, gateway: component.gateway)
          end
        end
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

        name, schema_block, relation_block =
          if args.size == 1
            ViewDSL.new(*args, &block).call
          else
            [*args, block]
          end

        block =
          if args.size == 2
            -> _ { schema.project(*args[1]) }
          else
            schema_block
          end

        schema(view: name, &block)

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

      # @api private
      def curried
        Curried
      end

      # @api private
      def default_name
        Name[id_from_class]
      end

      # @api private
      def infer_option(option, component:)
        meth = :"infer_#{option}"
        send(meth, component) if respond_to?(meth)
      end

      # @api private
      def infer_name(component)
        if (schema = components.schemas(view: false, provider: self).last)
          schema.name
        else
          Name[id_from_class]
        end
      end

      # @api private
      def infer_id(component)
        case component.type
        when :relation
          components.schemas(view: false, provider: self).last&.name.relation
        when :schema
          if component.option?(:name)
            component.name.relation
          else
            id_from_class
            Inflector.underscore((name || superclass.name).split("::").last).to_sym
          end
        else
          id_from_class
        end
      end

      # @api private
      def infer_adapter(component)
        adapter or raise(MissingAdapterIdentifierError, self)
      end

      # @api private
      def infer_gateway(component)
        gateway
      end

      # @api private
      def id_from_class
        Inflector.underscore((name || superclass.name).split("::").last).to_sym
      end
    end
  end
end
