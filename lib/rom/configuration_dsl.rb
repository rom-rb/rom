# frozen_string_literal: true

require "rom/relation/name"
require "rom/configuration_dsl/relation"
require "rom/configuration_dsl/command_dsl"
require "rom/configuration_dsl/mapper_dsl"

module ROM
  # This extends Configuration class with the DSL methods
  #
  # @api public
  module ConfigurationDSL
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
    def relation(name, options = EMPTY_HASH, &block)
      defaults = {inflector: inflector, adapter: default_adapter(options[:gateway])}

      klass = Relation.build_class(name, defaults.merge(options))
      klass.schema_opts(dataset: name, relation: name, **options)

      if block
        klass.class_eval(&block)
      end

      if klass.components.schemas.empty?
        klass.schema(name) {}
      end

      register_relation(klass, name: klass.components.schemas.first.name)

      klass
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
    def commands(relation, &block)
      CommandDSL.new(self, relation: relation, &block)
    end

    # Mapper definition DSL
    #
    # @api public
    def mappers(&block)
      MapperDSL.new(self, &block)
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
      plugin = plugin_registry[Inflector.singularize(type)].adapter(adapter).fetch(name)

      if block
        register_plugin(plugin.configure(&block))
      else
        register_plugin(plugin)
      end
    end

    # @api private
    def plugin_registry
      ROM.plugin_registry
    end

    # @api private
    def default_adapter(gateway)
      config.gateways[gateway || :default].adapter
    end
  end
end
