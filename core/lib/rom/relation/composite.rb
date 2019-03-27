# frozen_string_literal: true

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
        else
          relation.new(response)
        end
      end
      alias_method :[], :call

      # @see Relation#map_to
      #
      # @api public
      def map_to(klass)
        self >> left.map_to(klass).mapper
      end

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
