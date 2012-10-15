class Graph
  class Edge
    attr_reader :name

    attr_reader :left

    attr_reader :right

    def initialize(name, left, right)
      @name  = name
      @left  = left
      @right = right
      @nodes = Set.new([ @left, @right ])
    end

    def connects?(node)
      @nodes.include?(node)
    end
  end
end
