# frozen_string_literal: true

require "rom/registry"

module ROM
  # @api private
  class GatewayRegistry < Registry
    # @!attribute [r] config
    #   @return [Configurable::Config] Gateway configurations
    option :config

    # @api private
    def add(key, gateway)
      raise GatewayAlreadyDefinedError, "+#{key}+ is already defined" if key?(key)

      elements[key] = gateway
    end
  end
end
