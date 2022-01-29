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
        [*dataset_components.map(&:block), block].compact
      end

      # @api adapter
      def adapter
        config.adapter
      end

      # @api adapter
      def relation_id
        config.relation_id
      end

      private

      # @api private
      # rubocop:disable Metrics/AbcSize
      memoize def schema
        if id == relation_id
          resolver.schemas[id] if resolver.schemas.key?(id)
        elsif relation_id
          resolver.fetch("schemas.#{relation_id}.#{id}") {
            resolver.fetch("schemas.#{relation_id}")
          }
        elsif resolver.schemas.key?(id)
          resolver.schemas[id]
        end
      end
      # rubocop:enable Metrics/AbcSize

      # @api private
      memoize def dataset_components
        provider.components.datasets(abstract: true, adapter: adapter)
      end
    end
  end
end
