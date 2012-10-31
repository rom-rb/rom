module DataMapper

  # Graph representation of finalized relations
  #
  class RelationRegistry < Graph

    # Engine used in this registry
    #
    # @return [Engine]
    #
    # @api public
    attr_reader :engine

    # Relation node class that is used in this registry
    #
    # @see Engine#relation_node_class
    #
    # @return [Class]
    #
    # @api public
    attr_reader :node_class

    # Relation edge class that is used in this registry
    #
    # @see Engine#relation_edge_class
    #
    # @return [Class]
    #
    # @api public
    attr_reader :edge_class

    # Connector hash
    #
    # @return [Hash]
    #
    # @api public
    attr_reader :connectors

    # Initialize a new relation registry object
    #
    # @param [Engine]
    #
    # @return [undefined]
    #
    # @api private
    def initialize(engine)
      super()
      @engine     = engine
      @node_class = engine.relation_node_class
      @edge_class = engine.relation_edge_class
      @connectors = {}
    end

    # Register a new connector
    #
    # @param [Connector]
    #
    # @return [self]
    #
    # @api private
    def add_connector(connector)
      @connectors[connector.name] = connector
      self
    end

    # Freezes entire graph
    #
    # @return [self]
    #
    # @api private
    def freeze
      super
      @edges.freeze
      @nodes.freeze
      @connectors.freeze
      self
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
    # @return [RelationNode]
    #
    # @api private
    def build_node(*args)
      node_class.new(*args)
    end

    # Add new relation edge to the graph
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
    # @return [RelationEdge]
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
    # @return [RelationNode]
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
    # @return [RelationNode]
    #
    # @api private
    def node_for(relation)
      self[relation.name.to_sym]
    end

    # Returns an edge for the given left/right nodes
    #
    # @param [RelationNode] left relation node
    # @param [RelationNode] right relation node
    #
    # @return [RelationEdge, nil]
    #
    # @api private
    def edge_for(left, right)
      edges.detect { |edge| edge.left.equal?(left) && edge.right.equal?(right) }
    end

  end # class RelationRegistry
end # module DataMapper
