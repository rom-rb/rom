# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Dataset < Core
      # @api public
      def build
        if gateway?
          datasets.reduce(gateway.dataset(id)) { |dataset, component|
            if component.block
              dataset.instance_exec(schema, &component.block)
            else
              dataset
            end
          }
        else
          schema ? block.(schema) : block.()
        end
      end

      # @api public
      def abstract
        config[:abstract]
      end

      private

      # @api private
      def datasets
        # TODO: ensure abstract components don't get added multiple times
        provider.components.datasets(abstract: true).uniq(&:id).select { |ds| ds.id != id }
      end

      # @api private
      def schema
        registry.schemas[schema_key] if schema_key
      end

      # @api private
      def schema_key
        registry.components.get(:schemas, dataset: id)&.key
      end
    end
  end
end
