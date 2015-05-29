require 'rom/pipeline'

module ROM
  module Commands
    # Command graph
    #
    # @api private
    class Graph
      include Pipeline
      include Pipeline::Proxy

      attr_reader :root, :nodes

      alias_method :left, :root
      alias_method :right, :nodes

      # @api private
      def initialize(root, nodes)
        @root = root
        @nodes = nodes
      end

      # @api public
      def call(*args)
        left = root.call(*args)
        right = nodes.map { |node| node.call(left) }

        if result.equal?(:one)
          [[left], right]
        else
          [left, right]
        end
      end
    end
  end
end
