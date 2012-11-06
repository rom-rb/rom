class Graph
  class Edge
    include Equalizer.new(:name, :left, :right)

    # The edge name
    #
    # @example
    #
    #   left  = Node.new(:left)
    #   right = Node.new(:right)
    #   edge = Edge.new(:name, left, right)
    #   edge.name
    #
    # @return [Symbol]
    #
    # @api public
    attr_reader :name

    # The edge's left {Node}
    #
    # @example
    #
    #   left  = Node.new(:left)
    #   right = Node.new(:right)
    #   edge = Edge.new(:name, left, right)
    #   edge.left
    #
    # @return [Node]
    #
    # @api public
    attr_reader :left

    # The edge's right {Node}
    #
    # @example
    #
    #   left  = Node.new(:left)
    #   right = Node.new(:right)
    #   edge = Edge.new(:name, left, right)
    #   edge.right
    #
    # @return [Node]
    #
    # @api public
    attr_reader :right

    # Initialize a new edge
    #
    # @param [#to_sym] name
    #   the edge's name
    #
    # @param [Node] left
    #   the edge's left node
    #
    # @param [Node] right
    #   the edge's right node
    #
    # @return [undefined]
    #
    # @api private
    def initialize(name, left, right)
      @name  = name.to_sym
      @left  = left
      @right = right
      @nodes = Set[ left, right ]
    end

    # Tests wether this edge connects the given {Node}
    #
    # @example
    #
    #   left  = Node.new(:left)
    #   right = Node.new(:right)
    #   edge = Edge.new(:name, left, right)
    #   edge.connects?(left)
    #
    # @param [Node] node
    #   the node to test
    #
    # @return [Boolean]
    #   true if this edge connects +node+, false otherwise
    #
    # @api public
    def connects?(node)
      @nodes.include?(node)
    end
  end
end
