# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Dataset < Core
      # @api public
      def build
        return block.(provider) unless gateway?

        datasets.reduce(gateway.dataset(id)) { |dataset, component|
          if component.block
            dataset.instance_exec(schema, &component.block)
          else
            dataset
          end
        }
      end

      private

      # @api private
      def datasets
        provider.components.datasets
      end

      # @api private
      def schema
        configuration.schemas[id]
      end
    end
  end
end
