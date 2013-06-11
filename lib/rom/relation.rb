module ROM

  # Enhanced ROM relation wrapping axiom relation and using injected mapper to
  # load/dump tuples/objects
  #
  class Relation
    include Enumerable, Concord.new(:relation, :mapper)

    alias_method :all, :to_a

    def each(&block)
      return to_enum unless block_given?
      relation.each { |tuple| yield(mapper.load(tuple)) }
      self
    end

    def insert(object)
      new(relation.insert(mapper.dump(object)))
    end
    alias_method :<<, :insert

    def update(object)
      tuple = mapper.dump(object)
      new(relation.delete(tuple).insert(tuple))
    end

    def delete(object)
      new(relation.delete(mapper.dump(object)))
    end

    def replace(objects)
      new(relation.replace(objects.flat_map(&mapper.method(:dump))))
    end

    def restrict(*args, &block)
      new(relation.restrict(*args, &block))
    end

    def take(limit)
      new(relation.take(limit))
    end

    def first(limit = 1)
      take(limit)
    end

    def last(limit = 1)
      new(relation.reverse.take(limit).reverse)
    end

    def drop(offset)
      new(relation.drop(offset))
    end

    def order(*attributes)
      sorted = relation.sort_by { |r| attributes.map { |attribute| r.send(attribute) } }
      new(sorted)
    end

    def sort_by(*args, &block)
      new(relation.sort_by(*args, &block))
    end

    def ordered
      new(relation.sort_by(relation.header))
    end

    private

    def new(new_relation)
      self.class.new(new_relation, mapper)
    end

  end # class Relation

end # module ROM
