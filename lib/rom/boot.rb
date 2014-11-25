require 'rom/boot/dsl'
require 'rom/relation_builder'
require 'rom/reader_builder'

module ROM

  # Exposes DSL for defining schema, relations and mappers
  #
  # @api public
  class Boot
    include Equalizer.new(:repositories, :env)

    attr_reader :repositories, :adapter_relation_map, :env

    # @api private
    def initialize(repositories)
      @repositories = repositories
      @schema = {}
      @relations = {}
      @mappers = []
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
      @schema = DSL.new(self).schema(&block)
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

    # Finalize the setup
    #
    # @return [Env] frozen env with access to repositories, schema, relations and mappers
    #
    # @api public
    def finalize
      raise EnvAlreadyFinalizedError if env

      schema = load_schema
      relations = load_relations(schema)
      readers = load_readers(relations)

      @env = Env.new(repositories, schema, relations, readers)
    end

    # @api private
    def [](name)
      repositories.fetch(name)
    end

    # @api private
    def respond_to_missing?(name, include_context = false)
      repositories.key?(name)
    end

    private

    # @api private
    def method_missing(name, *args)
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

      builder = RelationBuilder.new(schema)

      relations = @relations.each_with_object({}) do |(name, block), h|
        adapter = adapter_relation_map[name]

        relation = builder.call(name) { |klass|
          adapter.extend_relation_class(klass)
          klass.class_eval(&block) if block
        }

        adapter.extend_relation_instance(relation)

        h[name] = relation
      end

      relations.each_value { |relation| relation.class.finalize(relations, relation) }

      RelationRegistry.new(relations)
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

  end

end
