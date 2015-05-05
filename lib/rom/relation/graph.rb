require 'rom/relation/composite'

module ROM
  class Relation
    # @api public
    class Graph
      attr_reader :root, :nodes

      def initialize(root, nodes)
        @root = root
        @nodes = nodes
      end

      # @api public
      def >>(other)
        Composite.new(self, other)
      end

      # @api public
      def call(*args)
        left = root.call(*args)
        right = nodes.map { |node| node.call(left) }

        [left, right]
      end
    end
  end
end
