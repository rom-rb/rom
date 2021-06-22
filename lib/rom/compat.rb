# frozen_string_literal: true

require_relative "compat/setup"

module ROM
  class Configuration
    def_delegators :@setup, :auto_registration
    def_delegators :@gateways, :gateways_map

    alias_method :environment, :gateways

    # @api private
    def relation_classes(gateway = nil)
      classes = setup.components.relations.map(&:constant)

      return classes unless gateway

      gw_name = gateway.is_a?(Symbol) ? gateway : gateways_map[gateway]
      classes.select { |rel| rel.gateway == gw_name }
    end

    # @api private
    # @deprecated
    def gateways_map
      @gateways_map ||= gateways.to_a.map(&:reverse).to_h
    end
  end
end
