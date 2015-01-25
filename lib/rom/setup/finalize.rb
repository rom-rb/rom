require 'rom/relation_builder'
require 'rom/reader_builder'
require 'rom/command_registry'

require 'rom/env'

module ROM
  class Setup
    # @private
    class Finalize
      attr_reader :repositories, :datasets, :repository_relation_map

      # @api private
      def initialize(repositories, relations, mappers, commands)
        @repositories = repositories
        @relations = relations
        @mappers = mappers
        @commands = commands
        @datasets = {}
        @repository_relation_map = {}
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
        builder = RelationBuilder.new(relations)

        @relations.each do |name, (options, block)|
          relations[name] = build_relation(name, builder, options, block)
        end

        datasets.each do |repository, schema|
          schema.each do |name|
            next if relations.key?(name)
            relations[name] = build_relation(name, builder, repository: repository)
          end
        end

        Relation.descendants.each do |klass|
          relations[klass.base_name] = klass.new(repositories[klass.repository])
        end

        relations.each_value do |relation|
          relation.class.finalize(relations, relation)
        end

        RelationRegistry.new(relations)
      end

      # @api private
      def build_relation(name, builder, options = {}, block = nil)
        repository = repositories[options.fetch(:repository) { :default }]

        relation = builder.call(name, repository) do |klass|
          methods = klass.public_instance_methods
          klass.class_eval(&block) if block
          klass.relation_methods = klass.public_instance_methods - methods
        end

        repository.extend_relation_instance(relation)
        repository_relation_map[name] = repository

        relation
      end

      # @api private
      def load_readers(relations)
        reader_builder = ReaderBuilder.new(relations)

        readers = @mappers.each_with_object({}) do |(name, options, block), h|
          h[name] = reader_builder.call(name, options, &block)
        end

        ReaderRegistry.new(readers)
      end

      # @api private
      def load_commands(relations)
        commands = @commands.each_with_object({}) do |(name, definitions), h|
          repository = repository_relation_map[name]

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
