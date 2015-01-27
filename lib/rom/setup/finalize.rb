require 'rom/reader_builder'
require 'rom/command_registry'

require 'rom/env'

module ROM
  class Setup
    # @private
    class Finalize
      attr_reader :repositories, :datasets

      # @api private
      def initialize(repositories, relations, mappers, commands)
        @repositories = repositories
        @relations = relations
        @mappers = mappers
        @commands = commands
        @datasets = {}
      end

      # @api private
      def run!
        load_datasets

        relations = load_relations
        readers = load_readers(relations)
        commands = load_commands(relations)

        Env.new(repositories, relations, readers, commands)
      end

      private

      # @api private
      def load_datasets
        repositories.each do |key, repository|
          datasets[key] = repository.schema
        end
      end

      # @api private
      def load_relations
        relations = {}

        datasets.each do |repository, schema|
          schema.each do |name|
            next if relations.key?(name)
            Relation.build_class(name).repository(repository)
          end
        end

        Relation.descendants.each do |klass|
          repository = repositories[klass.repository]
          dataset = repository.dataset(klass.base_name)

          repository.extend_relation_class(klass)
          relation = klass.new(dataset, relations)
          repository.extend_relation_instance(relation)

          relations[klass.base_name] = relation
        end

        relations.each_value do |relation|
          relation.class.finalize(relations, relation)
        end

        RelationRegistry.new(relations)
      end

      # @api private
      def load_readers(relations)
        reader_builder = ReaderBuilder.new(relations)

        readers = @mappers.each_with_object({}) do |(name, options, block), h|
          h[name] = reader_builder.call(name, options, &block)
        end

        Mapper.registry.each do |name, mappers|
          relation = relations[name]
          methods = relation.exposed_relations

          readers[name] = ReaderBuilder.build(
            name, relation, MapperRegistry.new(mappers), methods
          )
        end

        ReaderRegistry.new(readers)
      end

      # @api private
      def load_commands(relations)
        commands = @commands.each_with_object({}) do |(name, definitions), h|
          repository = repositories[relations[name].class.repository]

          rel_commands = {}

          definitions.each do |command_name, definition|
            rel_commands[command_name] = repository.command(
              command_name, relations[name], definition
            )
          end

          h[name] = CommandRegistry.new(rel_commands)
        end

        Registry.new(commands)
      end
    end
  end
end
