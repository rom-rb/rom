# frozen_string_literal: true

require "rom/registry"

module ROM
  # @api private
  class GatewayRegistry < Registry
    # @!attribute [r] config
    #   @return [Configurable::Config] Gateway configurations
    option :config

    # @!attribute [r] resolver
    #   @return [#call] optional item resolver
    option :resolver, optional: true

    # @api private
    def add(key, gateway)
      raise GatewayAlreadyDefinedError, "+#{key}+ is already defined" if key?(key)

      elements[key] = gateway
    end

    # @api public
    def fetch(key)
      if resolver
        super(key) { resolver[key] }
      else
        super
      end
    end
    alias_method :[], :fetch
  end
end
