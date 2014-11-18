require 'rom/boot/dsl'
require 'rom/relation_builder'
require 'rom/reader_builder'

module ROM

  class Boot
    attr_reader :repositories

    def initialize(repositories)
      @repositories = repositories
      @schema = {}
      @relations = {}
      @mappers = []
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
      adapter_relation_map = {}

      base_relations =
        if @schema.any?
          relations = @schema.each_with_object({}) do |(name, (dataset, header, adapter)), h|
            h[name] = Relation.new(dataset, header)
            adapter_relation_map[name] = adapter
          end
        else
          load_schema.each_with_object({}) do |(repo, schema), h|
            schema.each do |name, dataset, header|
              h[name] = Relation.new(dataset, header)
              adapter_relation_map[name] = repo.adapter
            end
          end
        end

      schema = Schema.new(base_relations)

      relations = @relations.each_with_object({}) do |(name, block), h|
        builder = RelationBuilder.new(name, schema, h)
        klass = builder.build_class

        adapter = adapter_relation_map[name]

        adapter.extend_relation_class(klass)
        relation = builder.call(klass, &block)
        adapter.extend_relation_instance(relation)

        h[name] = relation
      end

      relations.each_value { |relation| relation.class.finalize(relations, relation) }

      reader_builder = ReaderBuilder.new(relations)
      readers = @mappers.each_with_object({}) do |(name, options, block), h|
        h[name] = reader_builder.call(name, options, &block)
      end

      Env.new(
        repositories,
        schema,
        RelationRegistry.new(relations),
        ReaderRegistry.new(readers)
      )
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
      repositories.values.each_with_object({}) do |repo, h|
        h[repo] = repo.schema
      end
    end

  end

end
