# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Dataset < Core
      id :dataset

      option :constant, type: Types.Instance(Class)
      alias_method :relation_class, :constant

      option :block, optional: true, type: Types.Interface(:call)

      # @api public
      def namespace
        "datasets"
      end

      # @api public
      def id
        options[:id]
      end

      # @api public
      memoize def build
        datasets.reduce(canonical_dataset) { |dataset, component|
          if component.block
            dataset.instance_exec(schema, &component.block)
          else
            dataset
          end
        }
      end

      private

      # @api private
      memoize def canonical_dataset
        dataset = gateway.dataset(id)

        if block
          dataset.instance_exec(schema, &block)
        else
          dataset
        end
      end

      # @api private
      def schema
        configuration.schemas[id]
      end

      # @api private
      def datasets
        local_components.datasets(provider: relation_class.superclass)
      end
    end
  end
end
