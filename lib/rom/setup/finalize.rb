require 'rom/command_registry'
require 'rom/mapper_registry'

require 'rom/env'

module ROM
  class Setup
    # @private
    class Finalize
      attr_reader :repositories, :repo_adapter, :datasets, :relations

      # @api private
      def initialize(repositories, relations = {})
        @repositories = repositories
        @relations = relations
        @repo_adapter_map = ROM.repositories
        initialize_datasets
      end

      # @api private
      def adapter_for(repository)
        @repo_adapter_map.fetch(repositories[repository])
      end

      # @api private
      def run!
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
        relations = {}

        datasets.each do |repository, schema|
          schema.each do |name|
            next if @relations.key?(name)
            klass = Relation.build_class(name, adapter: adapter_for(repository))
            klass.repository(repository)
            klass.base_name(name)
          end
        end

        Relation.descendants.each do |klass|
          next unless klass.superclass != Relation

          repository = repositories[klass.repository]
          dataset = repository.dataset(klass.base_name)

          relation = klass.new(dataset, relations)
          repository.extend_relation_instance(relation)

          relations[klass.register_as] = relation
        end

        relations.each_value do |relation|
          relation.class.finalize(relations, relation)
        end

        RelationRegistry.new(relations)
      end

      # @api private
      def load_readers(relations)
        readers = {}

        Mapper.registry.each do |name, mappers|
          relation = relations[name]
          methods = relation.exposed_relations

          readers[name] = Reader.build(
            name, relation, MapperRegistry.new(mappers), methods
          )
        end

        ReaderRegistry.new(readers)
      end

      # @api private
      def load_commands(relations)
        registry = Command.registry(relations)

        commands = registry.each_with_object({}) do |(name, rel_commands), h|
          h[name] = CommandRegistry.new(rel_commands)
        end

        Registry.new(commands)
      end
    end
  end
end
