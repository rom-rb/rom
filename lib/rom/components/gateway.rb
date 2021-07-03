# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Gateway < Core
      id :gateway

      option :config

      # Relation registry id
      #
      # @return [Symbol]
      #
      # @api public
      def namespace
        "gateways"
      end

      # @return [Symbol]
      #
      # @api public
      def id
        options[:id] || :default
      end

      # @api public
      def adapter
        config.adapter
      end

      # @api public
      memoize def build
        gateway = adapter.is_a?(ROM::Gateway) ? adapter : setup

        # TODO: this is here to keep backward compatibility
        config.name = id
        gateway.instance_variable_set(:"@config", config)

        gateway.use_logger(config.logger) if config.key?(:logger)

        gateway
      end

      private

      # @api private
      def setup
        ROM::Gateway.setup(adapter, config)
      end
    end
  end
end
