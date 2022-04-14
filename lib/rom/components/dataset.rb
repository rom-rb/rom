# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Dataset < Core
      # @api public
      def build
        if gateway?
          blocks.reduce(gateway.dataset(id)) { |ds, blk| evaluate_block(ds, blk) }
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

      # @api private
      def evaluate_block(ds, block)
        ds.instance_exec(schema, &block)
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
          registry.schemas[id] if registry.schemas.key?(id)
        elsif relation_id
          registry.fetch("schemas.#{relation_id}.#{id}") {
            registry.fetch("schemas.#{relation_id}")
          }
        elsif registry.schemas.key?(id)
          registry.schemas[id]
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
