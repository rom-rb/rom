module DataMapper

  class RelationRegistry

    attr_reader :nodes
    attr_reader :edges

    def initialize
      @index = {}
      @nodes = Set.new
      @edges = EdgeSet.new
    end

    def add_edge(source, target, relationship = nil)
      edge = edges.add(source, target, relationship ? relationship.operation : nil)
      node = Node::Builder.build(edge)

      add_node(node)

      source.node.add_edge(edge, node, relationship)
      target.node.add_edge(edge, node)

      node
    end

    def contains?(relationship)
      nodes.any? { |node|
        node.connectors.any? { |name, connector|
          connector.relationship == relationship
        }
      }
    end

    def node_for(relation)
      if relation.respond_to?(:name)
        node(relation.name)
      else
        find_node(relation)
      end
    end

    def add_node(node)
      @nodes << node
      @index[node.name] = node
      self
    end

    def <<(relation)
      node = Node::Relation::Base.new(relation)
      add_node(node)
      relation
    end

    def node(name)
      @index[name.to_sym]
    end

    def [](name)
      node(name).relation
    end

    def relation_nodes
      @nodes.select { |node| !node.base_relation? }
    end

    def base_relation_nodes
      @nodes.select { |node| node.base_relation? }
    end

    private

    def find_node(relation)
      @nodes.detect { |node| node.relation == relation }
    end
  end # class RelationRegistry
end # module DataMapper
