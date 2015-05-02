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
      def each
        call.each { |root, node| yield(root, node) }
      end

      # @api public
      def call
        [root.call, node.call(root.call)]
      end
    end
  end
end
