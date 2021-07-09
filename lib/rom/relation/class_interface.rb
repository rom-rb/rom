# frozen_string_literal: true

require "set"

require "dry/effects"

require "rom/support/inflector"
require "rom/support/notifications"

require "rom/constants"
require "rom/relation/name"
require "rom/relation/view_dsl"
require "rom/schema"

module ROM
  class Relation
    # Global class-level API for relation classes
    #
    # @api public
    module ClassInterface
      extend Notifications::Listener

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

        schema(name, view: true, &block)

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
      def infer_option(option, component:)
        meth = :"infer_#{option}"
        send(meth, component) if respond_to?(meth)
      end

      # @api private
      def infer_id(component)
        case component.type
        when :schema
          component.provider.config.component.dataset
        when :relation
          component.constant.config.component.id
        when :dataset
          component.provider.config.component.id
        end
      end

      # @api private
      def infer_dataset(component)
        case component.type
        when :relation
          component.constant.config.component.dataset
        end
      end

      # @api private
      def infer_adapter(component)
        config.component.adapter or raise(MissingAdapterIdentifierError, self)
      end

      # @api private
      def infer_gateway(_)
        config.component.gateway
      end
    end
  end
end
