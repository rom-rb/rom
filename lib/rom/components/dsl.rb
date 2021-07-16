# frozen_string_literal: true

require "rom/relation/name"

require "rom/components/dsl/gateway"
require "rom/components/dsl/dataset"
require "rom/components/dsl/schema"
require "rom/components/dsl/relation"
require "rom/components/dsl/command"
require "rom/components/dsl/mapper"

module ROM
  # This extends Configuration class with the DSL methods
  #
  # @api public
  module Components
    module DSL
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
        __dsl__(DSL::Dataset, id: id, **options, &block)
      end

      # Specify a relation schema
      #
      # With a schema defined commands will set up a type-safe input handler automatically
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
      def schema(id = nil, **options, &block)
        __dsl__(DSL::Schema, id: id, **options, &block)
      end

      # Relation definition DSL
      #
      # @example
      #   setup.relation(:users) do
      #     def names
      #       project(:name)
      #     end
      #   end
      #
      # @api public
      def relation(id, dataset: id, **options, &block)
        __dsl__(DSL::Relation, id: id, dataset: dataset, **options, &block)
      end

      # Command definition DSL
      #
      # @example
      #   setup.commands(:users) do
      #     define(:create) do
      #       input NewUserParams
      #       result :one
      #     end
      #
      #     define(:update) do
      #       input UserParams
      #       result :many
      #     end
      #
      #     define(:delete) do
      #       result :many
      #     end
      #   end
      #
      # @api public
      def commands(relation, **options, &block)
        __dsl__(DSL::Command, relation: relation, **options, &block)
        components.commands
      end

      # Mapper definition DSL
      #
      # @api public
      def mappers(*_args, **options, &block)
        __dsl__(DSL::Mapper, **options, &block)
        components.mappers
      end

      # Configures a plugin for a specific adapter to be enabled for all relations
      #
      # @example
      #   config = ROM::Configuration.new(:sql, 'sqlite::memory')
      #
      #   config.plugin(:sql, relations: :instrumentation) do |p|
      #     p.notifications = MyNotificationsBackend
      #   end
      #
      #   config.plugin(:sql, relations: :pagination)
      #
      # @param [Symbol] adapter The adapter identifier
      # @param [Hash<Symbol=>Symbol>] spec Component identifier => plugin identifier
      #
      # @return [Plugin]
      #
      # @api public
      def plugin(adapter, spec, &block)
        type, name = spec.flatten(1)

        # TODO: plugin types are singularized, so this is not consistent
        #       with the configuration DSL for plugins that uses plural
        #       names of the components - this should be unified
        plugin = ROM
          .plugin_registry[Inflector.singularize(type)].adapter(adapter).fetch(name)
          .configure(&block)

        plugins << plugin

        plugin
      end

      # @api public
      def gateway(id, **options, &block)
        __dsl__(DSL::Gateway, id: id, **options, &block)
      end

      private

      # @api private
      def __dsl__(klass, **options, &block)
        type_config = config[klass.type].merge(options).inherit(config.component)

        if klass.nested
          dsl = klass.new(provider: self, config: type_config)
          dsl.instance_exec(&block)
          dsl
        else

          klass.new(provider: self, config: type_config, block: block).()
        end
      end
    end
  end
end
