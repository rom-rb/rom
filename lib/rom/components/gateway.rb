# frozen_string_literal: true

require_relative "core"
require "rom/open_struct"

module ROM
  module Components
    # @api public
    class Gateway < Core
      # @api public
      def adapter
        config[:adapter]
      end

      # @api public
      def build
        gateway = adapter.is_a?(ROM::Gateway) ? adapter : setup

        # TODO: this is here to keep backward compatibility
        config.update(name: id)
        gateway.instance_variable_set(:"@config", ROM::OpenStruct.new(config))

        gateway.use_logger(config[:logger]) if config.key?(:logger)

        gateway
      end

      private

      # @api private
      def setup
        if Array(config[:args]).empty?
          ROM::Gateway.setup(adapter, **config)
        else
          ROM::Gateway.setup(adapter, *config[:args])
        end
      end
    end
  end
end
