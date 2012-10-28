class Graph
  class Node
    attr_reader :name

    # @api private
    def initialize(name)
      @name = name.to_sym
    end
  end
end
