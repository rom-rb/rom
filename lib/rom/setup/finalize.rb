require 'rom/relation'
require 'rom/mapper'
require 'rom/reader'
require 'rom/command'

require 'rom/support/registry'
require 'rom/command_registry'
require 'rom/mapper_registry'

require 'rom/env'

module ROM
  class Setup
    # @private
    class Finalize
      attr_reader :repositories, :repo_adapter, :datasets

      # @api private
      def initialize(repositories)
        @repositories = repositories
        @repo_adapter_map = ROM.repositories
        initialize_datasets
      end

      # @api private
      def adapter_for(repository)
        @repo_adapter_map.fetch(repositories[repository])
      end

      # @api private
      def run!
        infer_schema_relations

        relations = load_relations
        readers = load_readers(relations)
        commands = load_commands(relations)

        Env.new(repositories, relations, readers, commands)
      end

      private

      # @api private
      def initialize_datasets
        @datasets = repositories.each_with_object({}) do |(key, repository), h|
          h[key] = repository.schema
        end
      end

      # @api private
      def load_relations
        relations = Relation.registry(repositories)
        RelationRegistry.new(relations)
      end

      # @api private
      def load_readers(relations)
        readers = {}

        Mapper.registry.each do |name, mappers|
          relation = relations[name]
          methods = relation.exposed_relations

          reader_class = Reader.descendants.detect { |klass| klass.relation == name }

          klass =
            if reader_class
              Reader.define_relation_methods(reader_class, methods)
            else
              Reader.build_class(relation, methods)
            end

          readers[name] = klass.new(name, relation, MapperRegistry.new(mappers))
        end

        ReaderRegistry.new(readers)
      end

      # @api private
      def load_commands(relations)
        registry = Command.registry(relations, repositories)

        commands = registry.each_with_object({}) do |(name, rel_commands), h|
          h[name] = CommandRegistry.new(rel_commands)
        end

        Registry.new(commands)
      end

      def infer_schema_relations
        datasets.each do |repository, schema|
          schema.each do |name|
            next if Relation.descendants.any? { |klass| klass.dataset == name }
            klass = Relation.build_class(name, adapter: adapter_for(repository))
            klass.repository(repository)
            klass.dataset(name)
          end
        end
      end
    end
  end
end
