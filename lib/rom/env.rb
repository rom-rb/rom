module ROM

  class Env
    include Concord::Public.new(:repositories)

    def initialize(repositories)
      super
      @schema = nil
      @mappers = nil
    end

    def relations(&block)
      @relations = RelationRegistry.define(schema, &block) if block
      @relations
    end

    def schema(&block)
      @schema = Schema.define(self, &block) if block
      @schema
    end

    def mappers(&block)
      @mappers = Mapping.define(schema, &block) if block
      @mappers
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
