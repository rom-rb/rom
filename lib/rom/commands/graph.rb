module ROM
  module Commands
    # Command graph
    #
    # @api private
    class Graph
      attr_reader :root, :nodes

      # @api private
      def initialize(root, nodes)
        @root = root
        @nodes = nodes
      end

      # @api public
      def call(*args)
        left = root.call(*args)
        right = nodes.map do |node|
          node.call(left)
        end
        [left, *right]
      end
    end
  end
end
