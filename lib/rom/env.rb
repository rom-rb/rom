module ROM

  class Env
    include Concord.new(:repositories)

    def initialize(repositories)
      super
      @schema = nil
      @readers = nil
    end

    def read(name)
      @readers[name]
    end

    def relations(&block)
      @relations = RelationRegistry.define(schema, &block) if block
      @relations
    end

    def schema(&block)
      @schema = Schema.define(self, &block) if block || @schema.nil?
      @schema
    end

    def mappers(&block)
      @readers = ReaderRegistry.define(relations, &block) if block
      @readers
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
