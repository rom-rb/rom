require 'rom/relation/loaded'
require 'rom/relation/materializable'
require 'rom/pipeline'

module ROM
  class Relation
    # Left-to-right relation composition used for data-pipelining
    #
    # @api public
    class Composite < Pipeline::Composite
      include Materializable

      # Call the pipeline by passing results from left to right
      #
      # Optional args are passed to the left object
      #
      # @return [Loaded]
      #
      # @api public
      def call(*args)
        relation = left.call(*args)
        response = right.call(relation)

        if response.is_a?(Loaded)
          response
        elsif relation.is_a?(Loaded)
          relation.new(response)
        else
          Loaded.new(relation, response)
        end
      end
      alias_method :[], :call

      private

      # @api private
      #
      # @see Pipeline::Proxy#decorate?
      #
      # @api private
      def decorate?(response)
        super || response.is_a?(Graph)
      end
    end
  end
end
