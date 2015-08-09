require 'rom/relation'
require 'rom/command'

require 'rom/support/registry'
require 'rom/relation_registry'
require 'rom/command_registry'
require 'rom/mapper_registry'

require 'rom/container'

module ROM
  class Setup
    # This giant builds an container using defined classes for core parts of ROM
    #
    # It is used by the setup object after it's done gathering class definitions
    #
    # @private
    class Finalize
      attr_reader :gateways, :repo_adapter, :datasets,
        :relation_classes, :mapper_classes, :mappers, :command_classes

      # @api private
      def initialize(gateways, relation_classes, mappers, command_classes)
        @gateways = gateways
        @repo_adapter_map = ROM.gateways
        @relation_classes = relation_classes
        @mapper_classes = mappers.select { |mapper| mapper.is_a?(Class) }
        @mappers = (mappers - @mapper_classes).reduce(:merge) || {}
        @command_classes = command_classes
        initialize_datasets
      end

      # Return adapter identifier for a given gateway object
      #
      # @return [Symbol]
      #
      # @api private
      def adapter_for(gateway)
        @repo_adapter_map.fetch(gateways[gateway])
      end

      # Run the finalization process
      #
      # This creates relations, mappers and commands
      #
      # @return [Container]
      #
      # @api private
      def run!
        infer_schema_relations

        relations = load_relations
        mappers = load_mappers
        commands = load_commands(relations)

        Container.new(gateways, relations, mappers, commands)
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
          h[key] = gateway.schema
        end
      end

      # Build entire relation registry from all known relation subclasses
      #
      # This includes both classes created via DSL and explicit definitions
      #
      # @api private
      def load_relations
        relations = Relation.registry(gateways, relation_classes)
        RelationRegistry.new(relations)
      end

      # @api private
      def load_mappers
        mapper_registry = Mapper.registry(mapper_classes).each_with_object({})

        registry_hash = mapper_registry.each { |(relation, mappers), h|
          h[relation] = MapperRegistry.new(mappers)
        }

        mappers.each do |relation, mappers|
          if registry_hash.key?(relation)
            mappers.each { |name, mapper| registry[name] = mapper }
          else
            registry_hash[relation] = MapperRegistry.new(mappers)
          end
        end

        Registry.new(registry_hash)
      end

      # Build entire command registries
      #
      # This includes both classes created via DSL and explicit definitions
      #
      # @api private
      def load_commands(relations)
        registry = Command.registry(relations, gateways, command_classes)

        commands = registry.each_with_object({}) do |(name, rel_commands), h|
          h[name] = CommandRegistry.new(rel_commands)
        end

        Registry.new(commands)
      end

      # For every dataset infered from gateways we infer a relation
      #
      # Relations explicitly defined are being skipped
      #
      # @api private
      def infer_schema_relations
        datasets.each do |gateway, schema|
          schema.each do |name|
            next if relation_classes.any? { |klass| klass.dataset == name }
            klass = Relation.build_class(name, adapter: adapter_for(gateway))
            klass.gateway(gateway)
            klass.dataset(name)
          end
        end
      end
    end
  end
end
