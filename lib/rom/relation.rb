module ROM

  # Enhanced ROM relation wrapping axiom relation and using injected mapper to
  # load/dump tuples/objects
  #
  class Relation
    attr_reader :axiom_relation, :mapper

    def initialize(axiom_relation, mapper)
      @axiom_relation = axiom_relation
      @mapper         = mapper
    end

    def all
      axiom_relation.to_a.map { |tuple| mapper.load(tuple) }
    end

  end # class Relation

end # module ROM
