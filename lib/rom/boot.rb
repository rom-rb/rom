require 'rom/boot/dsl'
require 'rom/relation_builder'
require 'rom/reader_builder'

module ROM

  class Boot
    attr_reader :repositories, :adapter_relation_map, :env

    def initialize(repositories)
      @repositories = repositories
      @schema = {}
      @relations = {}
      @mappers = []
      @adapter_relation_map = {}
      @env = nil
    end

    def schema(&block)
      @schema = DSL.new(self).schema(&block)
    end

    def relation(name, &block)
      @relations.update(name => block)
    end

    def mappers(&block)
      @mappers.concat(DSL.new(self).mappers(&block))
    end

    def finalize
      raise EnvAlreadyFinalizedError if env

      schema = load_schema
      relations = load_relations(schema)
      readers = load_readers(relations)

      @env = Env.new(repositories, schema, relations, readers)
    end

    def [](name)
      repositories.fetch(name)
    end

    def respond_to_missing?(name, include_context = false)
      repositories.key?(name)
    end

    private

    def method_missing(name, *args)
      repositories.fetch(name)
    end

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

    def load_relations(schema)
      relations = @relations.each_with_object({}) do |(name, block), h|
        builder = RelationBuilder.new(name, schema, h)
        adapter = adapter_relation_map[name]

        relation = builder.call { |klass|
          adapter.extend_relation_class(klass)
          klass.class_eval(&block) if block
        }

        adapter.extend_relation_instance(relation)

        h[name] = relation
      end

      relations.each_value { |relation| relation.class.finalize(relations, relation) }

      RelationRegistry.new(relations)
    end

    def load_readers(relations)
      reader_builder = ReaderBuilder.new(relations)

      readers = @mappers.each_with_object({}) do |(name, options, block), h|
        h[name] = reader_builder.call(name, options, &block)
      end

      RelationRegistry.new(readers)
    end

  end

end
