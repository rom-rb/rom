require 'rom/setup/dsl'
require 'rom/relation_builder'
require 'rom/reader_builder'
require 'rom/command_registry'

module ROM
  # Exposes DSL for defining schema, relations and mappers
  #
  # @api public
  class Setup
    include Equalizer.new(:repositories, :env)

    attr_reader :repositories, :adapter_relation_map, :env

    # @api private
    def initialize(repositories)
      @repositories = repositories
      @schema = {}
      @relations = {}
      @mappers = []
      @commands = {}
      @adapter_relation_map = {}
      @env = nil
    end

    # Schema definition DSL
    #
    # @example
    #
    #   setup.schema do
    #     base_relation(:users) do
    #       repository :sqlite
    #
    #       attribute :id
    #       attribute :name
    #     end
    #   end
    #
    # @api public
    def schema(&block)
      base_relations = DSL.new(self).schema(&block)
      base_relations.each do |repo, relations|
        (@schema[repo] ||= []).concat(relations)
      end
      self
    end

    # Relation definition DSL
    #
    # @example
    #
    #   setup.relation(:users) do
    #     def names
    #       project(:name)
    #     end
    #   end
    #
    # @api public
    def relation(name, &block)
      @relations.update(name => block)
      self
    end

    # Mapper definition DSL
    #
    # @example
    #
    #   setup.mappers do
    #     define(:users) do
    #       model name: 'User'
    #     end
    #
    #     define(:names, parent: :users) do
    #       exclude :id
    #     end
    #   end
    #
    # @api public
    def mappers(&block)
      @mappers.concat(DSL.new(self).mappers(&block))
      self
    end

    def commands(name, &block)
      @commands.update(name => DSL.new(self).commands(&block))
    end

    # Finalize the setup
    #
    # @return [Env] frozen env with access to repositories, schema, relations
    #               and mappers
    #
    # @api public
    def finalize
      raise EnvAlreadyFinalizedError if env

      schema = load_schema
      relations = load_relations(schema)
      readers = load_readers(relations)
      commands = load_commands(relations)

      @env = Env.new(repositories, schema, relations, readers, commands)
    end

    # @api private
    def [](name)
      repositories.fetch(name)
    end

    # @api private
    def respond_to_missing?(name, _include_context = false)
      repositories.key?(name)
    end

    private

    # @api private
    def method_missing(name, *_args)
      repositories.fetch(name)
    end

    # @api private
    def load_schema
      repositories.values.each do |repo|
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

      relation = builder.call(name) { |klass|
        adapter.extend_relation_class(klass)
        methods = klass.public_instance_methods

        klass.class_eval(&block) if block

        klass.relation_methods = klass.public_instance_methods - methods
      }

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
