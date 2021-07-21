# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Dataset < Core
      # @api public
      def build
        if gateway?
          blocks.reduce(gateway.dataset(id)) { |ds, blk|
            ds.instance_exec(schema, &blk)
          }
        elsif block
          schema ? block.(schema) : block.()
        else
          EMPTY_ARRAY
        end
      end

      # @api private
      def blocks
        [*datasets.map(&:block), block].compact
      end

      # @api adapter
      def adapter
        config.adapter
      end

      private

      # @api private
      def datasets
        provider.components.datasets(abstract: true, adapter: adapter)
      end

      # @api private
      def schema
        resolver.schemas[schema_key] if schema_key
      end

      # @api private
      def schema_key
        resolver.components.get(:schemas, dataset: id)&.key
      end
    end
  end
end
