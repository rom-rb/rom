module DataMapper

  # Graph representation of finalized relations
  #
  class RelationRegistry < Graph

    # Engine used in this registry
    #
    # @example
    #
    #   DataMapper[Person].relations.engine
    #
    # @return [Engine]
    #
    # @api public
    attr_reader :engine

    # Relation node class that is used in this registry
    #
    # @see Engine#relation_node_class
    #
    # @example
    #
    #   DataMapper[Person].relations.node_class
    #
    # @return [Node]
    #
    # @api public
    attr_reader :node_class

    # Relation edge class that is used in this registry
    #
    # @see Engine#relation_edge_class
    #
    # @example
    #
    #   DataMapper[Person].relations.edge_class
    #
    # @return [Edge]
    #
    # @api public
    attr_reader :edge_class

    # Connector hash
    #
    # @example
    #
    #   DataMapper[Person].relations.connectors
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
      @connectors[connector.name.to_sym] = connector
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
    # @param [Aliases,nil] aliases
    #
    # @return [Node]
    #
    # @api private
    def build_node(*args)
      node = node_for(args[1])
      return node if node
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
    # @return [Edge]
    #
    # @api private
    def build_edge(*args)
      edge_for(args.first) || edge_class.new(*args)
    end

    # Add new relation node to the graph
    #
    # @param [Object] relation
    #   an instance of the engine's relation class
    #
    # @return [self]
    #
    # @api private
    def <<(relation)
      new_node(relation.name, relation)
    end

    # Return relation node with the given name
    #
    # @example
    #
    #   DataMapper.engines[:default].relations[:people]
    #
    # @param [Symbol] name of the relation
    #
    # @return [Node]
    #
    # @api public
    def [](name)
      name = name.to_sym
      @nodes.detect { |node| node.name == name }
    end

    # Return relation node for the given relation
    #
    # @param [Object] relation
    #   an instance of the engine's relation class
    #
    # @return [Node] if a node for the given relation exists
    # @return [nil] otherwise
    #
    # @api private
    def node_for(relation)
      self[relation.name.to_sym]
    end

    # Returns the edge with the given name
    #
    # @param [#to_sym] name
    #   the edge's name
    #
    # @return [Edge] if an edge with the given name exists
    # @return [nil] otherwise
    #
    # @api private
    def edge_for(name)
      edges.detect { |edge| edge.name.to_sym == name.to_sym }
    end

    # The aliases used to join 2 of this registry's nodes
    #
    # @param [#to_s] relation_name
    #   the name of the relation wrapped by a node
    #
    # @param [Mapper::AttributeSet] attribute_set
    #   the attribute set to alias
    #
    # @return [Object] the aliases provided by a specific engine
    #
    # @api private
    def aliases(relation_name, attribute_set)
      node_class.aliases(relation_name, attribute_set)
    end
  end # class RelationRegistry
end # module DataMapper
