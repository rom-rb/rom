module DataMapper

  # Graph representation of finalized relations
  #
  class RelationRegistry < Graph

    def self.node_class
      RelationNode
    end

    def self.edge_class
      RelationConnector
    end

    def new_node(*args)
      add_node(self.class.node_class.new(*args))
    end

    def <<(relation)
      add_node(self.class.node_class.new(relation.name, relation))
      self
    end

    def [](name)
      @nodes.detect { |node| node.name == name }
    end

    def node_for(relation)
      self[relation.name]
    end

  end # class RelationRegistry
end # module DataMapper
