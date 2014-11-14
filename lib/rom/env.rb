module ROM

  class Env
    include Concord::Public.new(:repositories, :schema)

    def initialize(repositories, schema)
      super
      @relations = RelationRegistry.new
      @mappers = ReaderRegistry.new
    end

    def read(name)
      @mappers[name]
    end

    def relation(name, &block)
      relations << RelationBuilder.new(name, schema, relations).call(&block)
    end

    def relations(&block)
      if block
        @relations.call(schema, &block)
      else
        @relations
      end
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

    private

    def method_missing(name, *args)
      repositories.fetch(name)
    end
  end

end
