require 'set'
require 'data_mapper/support/graph/node'
require 'data_mapper/support/graph/edge'

class Graph

  # This graph's set of edges
  #
  # @example
  #
  #   graph = Graph.new
  #   graph.edges
  #
  # @return [Set<Edge>]
  #
  # @api public
  attr_reader :edges

  # This graph's set of nodes
  #
  # @example
  #
  #   graph = Graph.new
  #   graph.nodes
  #
  # @return [Set<Node>]
  #
  # @api public
  attr_reader :nodes

  # The class used to represent nodes in the graph
  #
  # @example
  #
  #   Graph.node_class
  #
  # @return [Node]
  #
  # @api public
  def self.node_class
    Node
  end

  # The class used to represent edges in the graph
  #
  # @example
  #
  #   Graph.edge_class
  #
  # @return [Edge]
  #
  # @api public
  def self.edge_class
    Edge
  end

  # Initialize a new instance of {Graph}
  #
  # @return [undefined]
  #
  # @api private
  def initialize
    @edges = Set.new
    @nodes = Set.new
  end

  # Build and add a new node to the graph
  #
  # @example
  #
  #   graph = Graph.new
  #   graph.new_node(:name)
  #
  # @param *args
  #   the arguments that {Node#initialize} accepts
  #
  # @return [undefined]
  #
  # @api public
  def new_node(*args)
    add_node(self.class.node_class.new(*args))
  end

  # Build and add a new edge to the graph
  #
  # @example
  #
  #   graph = Graph.new
  #   left  = Node.new(:left)
  #   right = Node.new(:right)
  #   graph.add_node(left)
  #   graph.add_node(right)
  #   graph.new_edge(:name, left, right)
  #
  # @param *args
  #   the arguments that {Edge#initialize} accepts
  #
  # @return [self]
  #
  # @api public
  def new_edge(*args)
    add_edge(self.class.edge_class.new(*args))
    self
  end

  # Add a node to the graph
  #
  # @example
  #
  #   graph = Graph.new
  #   node  = Node.new(:node)
  #   graph = graph.add_node(node)
  #
  # @param [Node] node
  #   the node to add to the graph
  #
  # @return [self]
  #
  # @api public
  def add_node(node)
    @nodes << node
    self
  end

  # Add an edge to the graph
  #
  # @example
  #
  #   graph = Graph.new
  #   left  = Node.new(:left)
  #   right = Node.new(:right)
  #   graph.add_node(left)
  #   graph.add_node(right)
  #   edge  = Edge.new(:name, left, right)
  #   graph = graph.add_edge(edge)
  #
  # @param [Edge] edge
  #   the edge to add to the graph
  #
  # @return [self]
  #
  # @api public
  def add_edge(edge)
    @edges << edge
    self
  end
end
