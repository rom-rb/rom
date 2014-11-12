module ROM

  class Env
    include Concord.new(:repositories)

    def initialize(repositories)
      super
      @schema = nil
      @relations = RelationRegistry.new
      @mappers = ReaderRegistry.new
    end

    def read(name)
      @mappers[name]
    end

    def relation(name, &block)
      relations << RelationBuilder.new(name, schema).call(&block)
    end

    def relations(&block)
      if block
        @relations.call(schema, &block)
      else
        @relations
      end
    end

    def schema(&block)
      @schema = Schema.define(self, &block) if block || @schema.nil?
      @schema
    end

    def mappers(&block)
      if block
        @mappers.call(relations, &block)
      else
        @mappers
      end
    end

    def [](name)
      repositories.fetch(name)
    end

    def respond_to_missing?(name, include_private = false)
      repositories.key?(name)
    end

    def load_schema
      repositories.map { |_, repo| repo.schema }.reduce(:+)
    end

    private

    def method_missing(name, *args)
      repositories.fetch(name)
    end
  end

end
