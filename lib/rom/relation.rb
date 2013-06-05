module ROM

  # Enhanced ROM relation wrapping graph nodes and using injected mapper to
  # load/dump tuples/objects
  #
  class Relation
    include Enumerable

    attr_reader :relation_node, :mapper

    alias_method :all, :to_a

    def initialize(relation_node, mapper)
      @relation_node = relation_node
      @mapper        = mapper
    end

    def each(&block)
      return to_enum unless block_given?
      relation_node.each { |tuple| yield(mapper.load(tuple)) }
      self
    end

    def restrict(query, &block)
      raise NotImplementedError
    end

    def order(*args)
      raise NotImplementedError
    end

  end # class Relation

end # module ROM
