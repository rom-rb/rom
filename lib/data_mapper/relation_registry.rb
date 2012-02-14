module DataMapper

  # RelationRegistry
  #
  class RelationRegistry

    # @api public
    def initialize(relations = {})
      @_relations = relations
    end

    # @api public
    def [](name)
      @_relations[name.to_sym]
    end

    # @api public
    def []=(name, relation)
      @_relations[name.to_sym] = relation
    end

    # @api public
    def <<(relation)
      self[relation.name] = relation
    end

  end # class RelationRegistry
end # module DataMapper
