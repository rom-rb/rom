module DataMapper

  # Graph representation of finalized relations
  #
  class RelationRegistry < Graph
    attr_reader :engine
    attr_reader :node_class
    attr_reader :edge_class
    attr_reader :connectors

    # @api private
    def initialize(engine)
      super()
      @engine     = engine
      @node_class = engine.relation_node_class
      @edge_class = engine.relation_edge_class
      @connectors = {}
    end

    # @api private
    def add_connector(connector)
      @connectors[connector.name] = connector
    end

    # @api private
    # TODO: add specs
    def reset
      self.class.new(engine)
    end

    # @api private
    # TODO: add specs
    def freeze
      super
      @edges.freeze
      @nodes.freeze
      @connectors.freeze
    end

    # Add new relation node to the graph
    #
    # @return [self]
    #
    # @api private
    def new_node(*args)
      add_node(build_node(*args))
    end

    # Build a new node
    #
    # @param [String,Symbol,#to_sym] name
    #
    # @param [Veritas::Relation] relation
    #
    # @param [AliasSet,nil] aliases
    #
    # @return [RelationRegistry::RelationNode]
    #
    # @api private
    def build_node(*args)
      node_class.new(*args)
    end

    # Add new relation connector to the graph
    #
    # @return [self]
    #
    # @api private
    # TODO: add specs
    def new_edge(*args)
      add_edge(build_edge(*args))
    end

    # Build a new edge
    #
    # @return [RelationRegistry::RelationConnector]
    #
    # @api private
    def build_edge(*args)
      edge_class.new(*args)
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
      name = name.to_sym
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

    # Returns an edge for the given left/right nodes
    #
    # @param [DataMapper::RelationRegistry::RelationNode] left relation node
    # @param [DataMapper::RelationRegistry::RelationNode] right relation node
    #
    # @return [DataMapper::RelationRegistry::RelationEdge, nil]
    #
    # @api private
    def edge_for(left, right)
      edges.detect { |edge| edge.left.equal?(left) && edge.right.equal?(right) }
    end

  end # class RelationRegistry
end # module DataMapper
