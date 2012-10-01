module DataMapper

  class RelationRegistry

    attr_reader :nodes
    attr_reader :edges

    def initialize
      @index = {}
      @nodes = Set.new
      @edges = EdgeSet.new
    end

    def add_edge(source, target, name)
      edge = edges.add(source, target)
      node = Node::Builder.build(edge)

      Mapper.relation_registry << node

      source.node.add_edge(edge, node, name)
      target.node.add_edge(edge, node)

      node
    end

    def node_for(relation)
      if relation.respond_to?(:name)
        node(relation.name)
      else
        find_node(relation)
      end
    end

    def <<(relation)
      node = Node::Relation::Base.new(relation)

      @nodes << node
      @index[node.name] = node

      relation
    end

    def node(name)
      @index[name.to_sym]
    end

    def [](name)
      node(name).relation
    end

    private

    def find_node(relation)
      @nodes.detect { |node| node.relation == relation }
    end
  end # class RelationRegistry
end # module DataMapper
