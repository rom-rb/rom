module DataMapper

  # Graph representation of finalized relations
  #
  class RelationRegistry < Graph
    attr_reader :engine
    attr_reader :node_class
    attr_reader :edge_class
    attr_reader :connectors

    def initialize(engine)
      super()
      @engine     = engine
      @node_class = engine.relation_node_class
      @edge_class = engine.relation_edge_class
      @connectors = {}
    end

    # @api private
    def reset
      self.class.new(engine)
    end

    # @api private
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
    def build_node(name, relation, aliases = nil)
      node_class.new(name.to_sym, relation, aliases)
    end

    # Add new relation connector to the graph
    #
    # @return [self]
    #
    # @api private
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

    # @api private
    def add_connector(connector)
      @connectors[connector.name] = connector
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
