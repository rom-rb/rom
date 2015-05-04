require 'rom/relation/composite'

module ROM
  class Relation
    # @api public
    class Graph
      attr_reader :root, :node

      def initialize(root, node)
        @root = root
        @node = node
      end

      # @api public
      def >>(other)
        Composite.new(self, other)
      end

      # @api public
      def call(*args)
        left = root.call(*args)
        right = node.call(left)

        [left, right]
      end
    end
  end
end
