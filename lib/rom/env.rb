module ROM

  class Env
    include Concord::Public.new(:repositories)

    class Reader
      include Enumerable

      attr_reader :name, :relation, :mappers

      def initialize(name, relation, mappers)
        @name = name
        @relation = relation
        @mappers = mappers
      end

      def each
        relation.each { |tuple| yield(mappers[name].load(tuple)) }
      end

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name)
      end

      private

      def method_missing(name, *args, &block)
        self.class.new(name, relation.public_send(name, *args, &block), mappers)
      end
    end

    def initialize(repositories)
      super
      @schema = nil
      @mappers = nil
      @readers = {}
    end

    def read(name)
      @readers[name] ||= Reader.new(name, relations[name], mappers[name])
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
      @mappers = MapperRegistry.define(schema, &block) if block
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
