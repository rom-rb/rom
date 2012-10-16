module DataMapper

  # Graph representation of finalized relations
  #
  class RelationRegistry < Graph

    # Return node class for this graph
    #
    # @return [Class]
    #
    # @api private
    def self.node_class
      RelationNode
    end

    # Return edge class for this graph
    #
    # @return [Class]
    #
    # @api private
    def self.edge_class
      RelationConnector
    end

    # Add new relation node to the graph
    #
    # @param [String,Symbol,#to_sym] name
    # @param [Veritas::Relation] relation
    # @param [AliasSet,nil] aliases
    #
    # @return [self]
    #
    # @api private
    def new_node(name, relation, aliases = nil)
      add_node(self.class.node_class.new(name.to_sym, relation, aliases))
    end

    # Add a new edge (relation connector) to the graph
    #
    # @return [self]
    #
    # @api private
    def new_edge(*args)
      @edges << self.class.edge_class.new(*args)
      self
    end

    # Add new relation node to the graph
    #
    # @param [Veritas::Relation] relation
    #
    # @return [self]
    #
    # @api private
    def <<(relation)
      new_node(relation.name, relation)
    end

    # Return relation node with the given name
    #
    # @param [Symbol] name of the relation
    #
    # @return [DataMapper::RelationRegistry::RelationNode]
    #
    # @api private
    def [](name)
      @nodes.detect { |node| node.name == name }
    end

    # Return relation node for the given relation
    #
    # @param [Veritas::Relation] relation
    #
    # @return [DataMapper::RelationRegistry::RelationNode]
    #
    # @api private
    def node_for(relation)
      self[relation.name.to_sym]
    end

  end # class RelationRegistry
end # module DataMapper
