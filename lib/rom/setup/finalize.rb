require 'rom/relation_builder'
require 'rom/reader_builder'
require 'rom/command_registry'

require 'rom/env'

module ROM
  class Setup
    # @private
    class Finalize
      attr_reader :repositories, :adapter_relation_map

      # @api private
      def initialize(repositories, schema, relations, mappers, commands)
        @repositories = repositories
        @schema = schema
        @relations = relations
        @mappers = mappers
        @commands = commands
        @adapter_relation_map = {}
      end

      # @api private
      def run!
        schema = load_schema
        relations = load_relations(schema)
        readers = load_readers(relations)
        commands = load_commands(relations)

        Env.new(repositories, schema, relations, readers, commands)
      end

      private

      # @api private
      def load_schema
        repositories.each_value do |repo|
          (@schema[repo] ||= []).concat(repo.schema)
        end

        base_relations = @schema.each_with_object({}) do |(repo, schema), h|
          schema.each do |name, dataset, header|
            adapter_relation_map[name] = repo.adapter
            h[name] = Relation.new(dataset, header)
          end
        end

        Schema.new(base_relations)
      end

      # @api private
      def load_relations(schema)
        return RelationRegistry.new unless adapter_relation_map.any?

        relations = {}
        builder = RelationBuilder.new(schema, relations)

        @relations.each do |name, block|
          relations[name] = build_relation(name, builder, block)
        end

        (schema.elements.keys - relations.keys).each do |name|
          relations[name] = build_relation(name, builder)
        end

        relations.each_value do |relation|
          relation.class.finalize(relations, relation)
        end

        RelationRegistry.new(relations)
      end

      # @api private
      def build_relation(name, builder, block = nil)
        adapter = adapter_relation_map[name]

        relation = builder.call(name) do |klass|
          adapter.extend_relation_class(klass)
          methods = klass.public_instance_methods

          klass.class_eval(&block) if block

          klass.relation_methods = klass.public_instance_methods - methods
        end

        adapter.extend_relation_instance(relation)

        relation
      end

      # @api private
      def load_readers(relations)
        return ReaderRegistry.new unless adapter_relation_map.any?

        reader_builder = ReaderBuilder.new(relations)

        readers = @mappers.each_with_object({}) do |(name, options, block), h|
          h[name] = reader_builder.call(name, options, &block)
        end

        ReaderRegistry.new(readers)
      end

      def load_commands(relations)
        return Registry.new unless relations.elements.any?

        commands = @commands.each_with_object({}) do |(name, definitions), h|
          adapter = adapter_relation_map[name]

          rel_commands = {}

          definitions.each do |command_name, definition|
            rel_commands[command_name] = adapter.command(
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
