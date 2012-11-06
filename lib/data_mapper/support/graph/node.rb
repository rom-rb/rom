class Graph
  class Node

    # The node name
    #
    # @example
    #
    #   node = Node.new(:name)
    #   node.name
    #
    # @return [Symbol]
    #
    # @api public
    attr_reader :name

    # Initialize a new node
    #
    # @param [#to_sym] name
    #   the node name
    #
    # @return [undefined]
    #
    # @api private
    def initialize(name)
      @name = name.to_sym
    end
  end
end
