require 'set'
require 'data_mapper/support/graph/node'
require 'data_mapper/support/graph/edge'

class Graph
  attr_reader :edges

  attr_reader :nodes

  def initialize
    @edges = Set.new
    @nodes = Set.new
  end

  def new_node(name)
    add_node(Node.new(name))
  end

  def new_edge(name, left, right)
    add_edge(Edge.new(name, left, right))
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
