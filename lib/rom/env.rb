module ROM

  class Env
    include Concord::Public.new(:repositories)

    def initialize(repositories)
      super
      @schema = nil
      @readers = nil
    end

    def read(name)
      @readers[name]
    end

    def relations(&block)
      @relations = RelationRegistry.define(schema, mappers, &block) if block
      @relations
    end

    def schema(&block)
      @schema = Schema.define(self, &block) if block
      @schema
    end

    def mappers(&block)
      @readers = MapperRegistry.define(relations, &block) if block
      @readers
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
