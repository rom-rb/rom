require 'set'
require 'data_mapper/support/graph/node'
require 'data_mapper/support/graph/edge'

class Graph
  attr_reader :edges

  attr_reader :nodes

  def self.node_class
    Node
  end

  def self.edge_class
    Edge
  end

  def initialize
    @edges = Set.new
    @nodes = Set.new
  end

  def new_node(name)
    add_node(self.class.node_class.new(name))
  end

  def new_edge(name, left, right)
    add_edge(self.class.edge_class.new(name, left, right))
    self
  end

  def add_node(node)
    @nodes << node
    self
  end

  def add_edge(edge)
    @edges << edge
    self
  end

  def edges_for(node)
    edges.select { |edge| edge.connects?(node) }
  end
end
