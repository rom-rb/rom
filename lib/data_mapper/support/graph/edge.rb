class Graph
  class Edge
    include Equalizer.new(:name, :left, :right)

    attr_reader :name
    attr_reader :left
    attr_reader :right

    def initialize(name, left, right)
      @name  = name.to_sym
      @left  = left
      @right = right
      @nodes = Set[ left, right ]
    end

    def connects?(node)
      @nodes.include?(node)
    end
  end
end
