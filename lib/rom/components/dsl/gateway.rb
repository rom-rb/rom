# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # @private
      class Gateway < Core
        key :gateways

        # @api private
        def call
          add(config: provider_defaults)
        end

        # @api private
        def id
          config[:id]
        end

        # @api private
        def provider_defaults
          return EMPTY_HASH if provider.config.gateways.key?(id)
          provider.config.gateways[id].config
        end
      end
    end
  end
end
