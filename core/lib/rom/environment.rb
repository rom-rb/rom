# frozen_string_literal: true

require 'rom/support/configurable'
require 'rom/gateway'

module ROM
  # Core gateway configuration interface
  #
  # @api private
  class Environment
    include Configurable

    attr_reader :gateways, :gateways_map

    # @api private
    def initialize(*args)
      @gateways = {}
      @gateways_map = {}

      configure_gateways(*args) unless args.empty?
    end

    private

    # @api private
    def configure_gateways(*args)
      normalized_gateway_args = normalize_gateway_args(*args)
      normalized_gateways = normalize_gateways(normalized_gateway_args)

      @gateways, @gateways_map = normalized_gateways.values_at(:gateways, :map)

      normalized_gateway_args.each_with_object(config) do |(name, gateway_config), config|
        options = gateway_config.is_a?(Array) && gateway_config.last
        load_config(config.gateways[name], options) if options.is_a?(Hash)
      end
    end

    # @api private
    def normalize_gateway_args(*args)
      args.first.is_a?(Hash) ? args.first : { default: args }
    end

    # Build gateways using the setup interface
    #
    # @api private
    def normalize_gateways(gateways_config)
      gateways_config.each_with_object(map: {}, gateways: {}) do |(name, spec), hash|
        identifier, *args = Array(spec)

        if identifier.is_a?(Gateway)
          gateway = identifier
        else
          gateway = Gateway.setup(identifier, *args.flatten)
        end

        hash[:map][gateway] = name
        hash[:gateways][name] = gateway
      end
    end

    # @api private
    def load_config(config, hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          load_config(config[key], value)
        else
          config.send("#{key}=", value)
        end
      end
    end
  end
end
