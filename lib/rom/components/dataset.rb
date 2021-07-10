# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Dataset < Core
      # @!attribute [r] gateway
      #   @return [Symbol] Gateway identifier
      option :gateway, inferrable: true, type: Types::Strict::Symbol

      # @!attribute [r] gateway
      #   @return [Proc] Optional dataset evaluation block
      option :block, optional: true, type: Types.Interface(:to_proc)

      # @api public
      memoize def build
        datasets.reduce(_gateway.dataset(id)) { |dataset, component|
          if component.block
            dataset.instance_exec(schema, &component.block)
          else
            dataset
          end
        }
      end

      private

      # @api private
      memoize def datasets
        provider.components.datasets(abstract: true)
      end

      # @api private
      def schema
        configuration.schemas[id]
      end
    end
  end
end
