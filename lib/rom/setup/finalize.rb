require 'rom/command_registry'
require 'rom/mapper_registry'

require 'rom/env'

module ROM
  class Setup
    # @private
    class Finalize
      attr_reader :repositories, :repo_adapter, :datasets

      # @api private
      def initialize(options = {})
        @repositories = options.fetch(:repositories)
        @relation_classes = options.fetch(:relation_classes)
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
        registry = {}

        @relation_classes.each do |name, klass|
          # TODO: raise a meaningful error here and add spec covering the case
          #       where klass' repository points to non-existant repo
          repository = repositories.fetch(klass.repository)
          dataset = repository.dataset(klass.base_name)

          relation = klass.new(dataset, registry)
          registry[name] = relation
        end

        registry.each_value do |relation|
          relation.class.finalize(registry, relation)
        end

        RelationRegistry.new(registry)
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
        registry = Command.registry(relations, repositories)

        commands = registry.each_with_object({}) do |(name, rel_commands), h|
          h[name] = CommandRegistry.new(rel_commands)
        end

        Registry.new(commands)
      end

      def infer_schema_relations
        datasets.each do |repository, schema|
          schema.each do |name|
            next if @relation_classes.values.any? { |klass| klass.base_name == name }
            klass = Relation.build_class(name, adapter: adapter_for(repository))
            klass.repository(repository)
            klass.base_name(name)
            @relation_classes[name] = klass
          end
        end
      end
    end
  end
end
