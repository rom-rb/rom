require 'dry/equalizer'

require 'rom/initializer'

require 'rom/relation/loaded'
require 'rom/relation/composite'
require 'rom/relation/materializable'
require 'rom/pipeline'
require 'rom/support/memoizable'

module ROM
  class Relation
    # Abstract relation graph class
    #
    # @api public
    class Graph
      extend Initializer

      include Memoizable

      # @!attribute [r] root
      #   @return [Relation] The root relation
      param :root

      # @!attribute [r] nodes
      #   @return [Array<Relation>] An array with relation nodes
      param :nodes

      include Dry::Equalizer(:root, :nodes)
      include Materializable
      include Pipeline
      include Pipeline::Proxy

      # for compatibility with the pipeline
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

      # @see Relation#map_with
      #
      # @api public
      def map_with(*args)
        self.class.new(root.map_with(*args), nodes)
      end

      # @see Relation#map_to
      #
      # @api public
      def map_to(klass)
        self.class.new(root.map_to(klass), nodes)
      end

      # @see Relation#mapper
      #
      # @api private
      def mapper
        mappers[to_ast]
      end

      # @api private
      memoize def to_ast
        [:relation, [name.relation, attr_ast + nodes.map(&:to_ast), meta_ast]]
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
