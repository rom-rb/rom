module ROM

  # Enhanced ROM relation wrapping axiom relation and using injected mapper to
  # load/dump tuples/objects
  #
  class Relation
    include Enumerable, Proxy, Concord::Public.new(:relation, :mapper)

    alias_method :all, :to_a

    def each(&block)
      return to_enum unless block_given?
      relation.each { |tuple| yield(mapper.load(tuple)) }
      self
    end

    def insert(object)
      new(relation.insert([mapper.dump(object)]))
    end
    alias_method :<<, :insert

    def update(object)
      tuple = mapper.dump(object)
      new(relation.delete([tuple]).insert([ tuple ]))
    end

    def delete(object)
      new(relation.delete([mapper.dump(object)]))
    end

    def replace(objects)
      new(relation.replace(objects.map(&mapper.method(:dump))))
    end

    def first(*args)
      new(sorted.first(*args)).all.first
    end

    def last(*args)
      new(sorted.last(*args)).all.first
    end

    def inject_mapper(mapper)
      new(relation, mapper)
    end

    private

    def new(new_relation, new_mapper = mapper)
      self.class.new(new_relation, new_mapper)
    end

    def sorted
      relation.sort_by(header)
    end

  end # class Relation

end # module ROM
