module DataMapper

  class << self
    def relation_registry
      @_relation_registry ||= RelationRegistry.new
    end
  end

  # RelationRegistry
  #
  class RelationRegistry

    # @api public
    def initialize(relations = {})
      @relations = relations
    end

    # @api public
    def [](name)
      @relations[name.to_sym]
    end

    # @api public
    def []=(name, relation)
      @relations[name.to_sym] = relation
    end

    # @api public
    def <<(relation)
      self[relation.name] = relation
    end

  end # class RelationRegistry
end # module DataMapper
