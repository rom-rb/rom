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
    attr_reader :gateways, :repo_adapter, :datasets, :gateway_map,
      :relation_classes, :mapper_classes, :mapper_objects, :command_classes, :plugins, :config

    # @api private
    def initialize(options)
      @gateways = options.fetch(:gateways)
      @gateway_map = options.fetch(:gateway_map)

      @relation_classes = options.fetch(:relation_classes)
      @command_classes = options.fetch(:command_classes)

      mappers = options.fetch(:mappers, [])
      @mapper_classes = mappers.select { |mapper| mapper.is_a?(Class) }
      @mapper_objects = (mappers - @mapper_classes).reduce(:merge) || {}

      @config = options.fetch(:config)

      @plugins = options.fetch(:plugins)

      initialize_datasets
    end

    # Return adapter identifier for a given gateway object
    #
    # @return [Symbol]
    #
    # @api private
    def adapter_for(gateway)
      @gateway_map.fetch(gateways[gateway])
    end

    # Run the finalization process
    #
    # This creates relations, mappers and commands
    #
    # @return [Container]
    #
    # @api private
    def run!
      infer_relations

      mappers = load_mappers
      relations = load_relations(mappers)
      commands = load_commands(relations)

      container = Container.new(gateways, relations, mappers, commands)
      container.freeze
      container
    end

    private

    # Infer all datasets using configured gateways
    #
    # Not all gateways can do that, by default an empty array is returned
    #
    # @return [Hash] gateway name => array with datasets map
    #
    # @api private
    def initialize_datasets
      @datasets = gateways.each_with_object({}) do |(key, gateway), h|
        infer_relations = config.gateways && config.gateways[key] && config.gateways[key][:infer_relations]
        h[key] = gateway.schema if infer_relations
      end
    end

    # Build entire relation registry from all known relation subclasses
    #
    # This includes both classes created via DSL and explicit definitions
    #
    # @api private
    def load_relations(mappers)
      FinalizeRelations.new(
        gateways,
        relation_classes,
        mappers: mappers, plugins: plugins.select(&:relation?)
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
      FinalizeCommands.new(relations, gateways, command_classes).run!
    end

    # For every dataset infered from gateways we infer a relation
    #
    # Relations explicitly defined are being skipped
    #
    # @api private
    def infer_relations
      datasets.each do |gateway, schema|
        schema.each do |name|
          if infer_relation?(gateway, name)
            klass = ROM::ConfigurationDSL::Relation.build_class(name, adapter: adapter_for(gateway))
            klass.gateway(gateway)
            klass.dataset(name, deprecation: false)
            @relation_classes << klass
          else
            next
          end
        end
      end
    end

    def infer_relation?(gateway, name)
      inferrable_relations(gateway).include?(name) && relation_classes.none? { |klass|
        klass.dataset == name
      }
    end

    def inferrable_relations(gateway)
      gateway_config = config.gateways[gateway]
      schema = gateways[gateway].schema

      allowed = gateway_config[:inferrable_relations] || schema
      skipped = gateway_config[:not_inferrable_relations] || []

      schema & allowed - skipped
    end
  end
end
