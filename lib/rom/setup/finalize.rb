require 'rom/relation'
require 'rom/mapper'
require 'rom/command'

require 'rom/support/registry'
require 'rom/command_registry'
require 'rom/mapper_registry'

require 'rom/env'

module ROM
  class Setup
    # This giant builds an environment using defined classes for core parts of ROM
    #
    # It is used by the setup object after it's done gathering class definitions
    #
    # @private
    class Finalize
      attr_reader :repositories, :repo_adapter, :datasets,
        :relation_classes, :mapper_classes, :mappers, :command_classes

      # @api private
      def initialize(repositories, relation_classes, mappers, command_classes)
        @repositories = repositories
        @repo_adapter_map = ROM.repositories
        @relation_classes = relation_classes
        @mapper_classes = mappers.select { |mapper| mapper.is_a?(Class) }
        @mappers = (mappers - @mapper_classes).reduce(:merge) || {}
        @command_classes = command_classes
        initialize_datasets
      end

      # Return adapter identifier for a given repository object
      #
      # @return [Symbol]
      #
      # @api private
      def adapter_for(repository)
        @repo_adapter_map.fetch(repositories[repository])
      end

      # Run the finalization process
      #
      # This creates relations, mappers and commands
      #
      # @return [Env]
      #
      # @api private
      def run!
        infer_schema_relations

        relations = load_relations
        mappers = load_mappers
        commands = load_commands(relations)

        Env.new(repositories, relations, mappers, commands)
      end

      private

      # Infer all datasets using configured repositories
      #
      # Not all repositories can do that, by default an empty array is returned
      #
      # @return [Hash] repository name => array with datasets map
      #
      # @api private
      def initialize_datasets
        @datasets = repositories.each_with_object({}) do |(key, repository), h|
          h[key] = repository.schema
        end
      end

      # Build entire relation registry from all known relation subclasses
      #
      # This includes both classes created via DSL and explicit definitions
      #
      # @api private
      def load_relations
        relations = Relation.registry(repositories, relation_classes)
        RelationRegistry.new(relations)
      end

      # @api private
      def load_mappers
        mapper_registry = Mapper.registry(mapper_classes).each_with_object({})

        registry_hash = mapper_registry.each do |(relation, mappers), h|
          h[relation] = MapperRegistry.new(mappers)
        end

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
        registry = Command.registry(relations, repositories, command_classes)

        commands = registry.each_with_object({}) do |(name, rel_commands), h|
          h[name] = CommandRegistry.new(rel_commands)
        end

        Registry.new(commands)
      end

      # For every dataset infered from repositories we infer a relation
      #
      # Relations explicitly defined are being skipped
      #
      # @api private
      def infer_schema_relations
        datasets.each do |repository, schema|
          schema.each do |name|
            next if relation_classes.any? { |klass| klass.dataset == name }
            klass = Relation.build_class(name, adapter: adapter_for(repository))
            klass.repository(repository)
            klass.dataset(name)
          end
        end
      end
    end
  end
end
