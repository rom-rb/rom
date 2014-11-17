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
      base_relations =
        if @schema.any?
          relations = @schema.each_with_object({}) do |(name, args), h|
            h[name] = Relation.new(*args)
          end
        else
          load_schema.each_with_object({}) do |(name, dataset, header, ext), h|
            relation = Relation.new(dataset, header)
            relation.extend(ext) if ext

            h[name] = relation
          end
        end

      schema = Schema.new(base_relations)

      relations = @relations.each_with_object({}) do |(name, block), h|
        h[name] = RelationBuilder.new(name, schema, h).call(&block)
      end

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
      repositories.values.map { |repo| repo.schema }.reduce(:+)
    end

  end

end
