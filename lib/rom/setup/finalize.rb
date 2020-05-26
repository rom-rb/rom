# frozen_string_literal: true

require 'rom/relation'
require 'rom/command'

require 'rom/registry'
require 'rom/command_registry'
require 'rom/mapper_registry'

require 'rom/container'
require 'rom/setup/finalize/finalize_commands'
require 'rom/setup/finalize/finalize_relations'
require 'rom/setup/finalize/finalize_mappers'

# temporary
require 'rom/configuration_dsl/relation'

module ROM
  # This giant builds an container using defined classes for core parts of ROM
  #
  # It is used by the setup object after it's done gathering class definitions
  #
  # @private
  class Finalize
    attr_reader :gateways, :repo_adapter,
                :relation_classes, :mapper_classes, :mapper_objects,
                :command_classes, :plugins, :config, :notifications

    # @api private
    def initialize(options)
      @gateways = options.fetch(:gateways)

      @relation_classes = options.fetch(:relation_classes)
      @command_classes = options.fetch(:command_classes)

      mappers = options.fetch(:mappers, [])
      @mapper_classes = mappers.select { |mapper| mapper.is_a?(Class) }
      @mapper_objects = (mappers - @mapper_classes).reduce(:merge) || {}

      @config = options.fetch(:config)
      @notifications = options.fetch(:notifications)

      @plugins = options.fetch(:plugins)
    end

    # Return adapter identifier for a given gateway object
    #
    # @return [Symbol]
    #
    # @api private
    def adapter_for(gateway)
      gateways[gateway].adapter
    end

    # Run the finalization process
    #
    # This creates relations, mappers and commands
    #
    # @return [Container]
    #
    # @api private
    def run!
      mappers = load_mappers
      relations = load_relations(mappers)
      commands = load_commands(relations)

      container = Container.new(gateways, relations, mappers, commands)
      container.freeze
      container
    end

    private

    # Build entire relation registry from all known relation subclasses
    #
    # This includes both classes created via DSL and explicit definitions
    #
    # @api private
    def load_relations(mappers)
      global_plugins = plugins.select { |p| p.type == :relation || p.type == :schema }

      FinalizeRelations.new(
        gateways,
        relation_classes,
        mappers: mappers,
        plugins: global_plugins,
        notifications: notifications
      ).run!
    end

    # @api private
    def load_mappers
      FinalizeMappers.new(mapper_classes, mapper_objects).run!
    end

    # Build entire command registries
    #
    # This includes both classes created via DSL and explicit definitions
    #
    # @api private
    def load_commands(relations)
      FinalizeCommands.new(relations, gateways, command_classes, notifications).run!
    end
  end
end
