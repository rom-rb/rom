module ROM

  # Enhanced ROM relation wrapping axiom relation and using injected mapper to
  # load/dump tuples/objects
  #
  class Relation
    include Enumerable

    attr_reader :axiom_relation, :mapper

    def initialize(axiom_relation, mapper)
      @axiom_relation = axiom_relation
      @mapper         = mapper
    end

    def each(&block)
      return to_enum unless block_given?
      axiom_relation.each(&block)
      self
    end

    def all
      axiom_relation.to_a.map { |tuple| mapper.load(tuple) }
    end

    def restrict(query, &block)
      raise NotImplementedError
    end

    def order(*args)
      raise NotImplementedError
    end

  end # class Relation

end # module ROM
