module ROM

  class Reader
    include Enumerable
    include Equalizer.new(:name, :relation, :mapper)

    attr_reader :name, :relation, :mappers, :mapper

    def initialize(name, relation, mappers)
      @name = name
      @relation = relation
      @mappers = mappers
      @mapper = mappers.fetch(name) { mappers.fetch(relation.name) }
    end

    def each
      relation.each { |tuple| yield(mapper.load(tuple)) }
    end

    def respond_to_missing?(name, include_private = false)
      relation.respond_to?(name)
    end

    private

    def method_missing(name, *args, &block)
      self.class.new(name, relation.public_send(name, *args, &block), mappers)
    end

  end

end
