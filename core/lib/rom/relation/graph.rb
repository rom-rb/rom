require 'dry/equalizer'

require 'rom/initializer'

require 'rom/relation/loaded'
require 'rom/relation/composite'
require 'rom/relation/materializable'
require 'rom/pipeline'

module ROM
  class Relation
    # Abstract relation graph class
    #
    # @api public
    class Graph
      extend Initializer

      param :root

      param :nodes

      include Dry::Equalizer(:root, :nodes)
      include Materializable
      include Pipeline
      include Pipeline::Proxy

      # Root aka parent relation
      #
      # @return [Relation]
      #
      # @api private
      attr_reader :root

      # Child relation nodes
      #
      # @return [Array<Relation>]
      #
      # @api private
      attr_reader :nodes

      alias_method :left, :root
      alias_method :right, :nodes

      # @api public
      def with_nodes(nodes)
        self.class.new(root, nodes)
      end

      # Return if this is a graph relation
      #
      # @return [true]
      #
      # @api private
      def graph?
        true
      end

      # @api public
      def map_with(*args)
        self.class.new(root.map_with(*args), nodes)
      end

      # @api public
      def map_to(klass)
        self.class.new(root.map_to(klass), nodes)
      end

      # @api private
      def mapper
        mappers[to_ast]
      end

      private

      # @api private
      def decorate?(other)
        super || other.is_a?(Composite) || other.is_a?(Curried)
      end

      # @api private
      def composite_class
        Relation::Composite
      end
    end
  end
end
