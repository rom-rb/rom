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
    def self.element_not_found_error
      GatewayMissingError
    end

    # @api private
    def add(key, gateway)
      raise GatewayAlreadyDefinedError, "+#{key}+ is already defined" if key?(key)

      elements[key] = gateway
    end

    # @api public
    def fetch(key, &block)
      if resolver
        elements.fetch(key) { resolver[key] || block&.call || not_found(key) }
      else
        elements.fetch(key) { block&.call || not_found(key) }
      end
    end
    alias_method :[], :fetch

    private

    # @api private
    def not_found(key)
      raise(self.class.element_not_found_error.new(key, self))
    end
  end
end
