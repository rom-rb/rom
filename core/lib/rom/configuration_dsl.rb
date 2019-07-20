# frozen_string_literal: true

require 'rom/configuration_dsl/relation'
require 'rom/configuration_dsl/command_dsl'
require 'rom/configuration_dsl/mapper_dsl'

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
      klass_opts = { adapter: default_adapter }.merge(options)
      klass = Relation.build_class(name, klass_opts)
      klass.schema_opts(dataset: name, relation: name)
      klass.class_eval(&block) if block
      register_relation(klass)
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
    def commands(name, &block)
      register_command(*CommandDSL.new(name, default_adapter, &block).command_classes)
    end

    # Mapper definition DSL
    #
    # @api public
    def mappers(&block)
      register_mapper(*MapperDSL.new(self, mapper_classes, block).mapper_classes)
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
      plugin = plugin_registry[type].adapter(adapter).fetch(name) do
        plugin_registry[type].fetch(name)
      end

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
  end
end
