module ROM

  class Env
    include Adamantium::Flat

    attr_reader :repositories, :schema, :relations, :mappers

    def initialize(repositories, schema, relations, mappers)
      @repositories = repositories
      @schema = schema
      @relations = relations
      @mappers = mappers
    end

    def read(name)
      mappers[name]
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
